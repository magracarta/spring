<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 월 예정사항 등록 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style type="text/css">

        /* 커스텀 파랑 */
        .my-blue-style {
            color : #0000ff;
        }
        /* 커스텀 회색 */
        .my-gray-style {
            color : #aaaaaa;
        }
    </style>
	<script type="text/javascript">

		var auiGrid;
		var rowNo = 0;
		var checkPrePlanYn = "N";
		var planJson = JSON.parse('${codeMapJsonObj['PLAN_STATUS']}');
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
			fnCheckPlanMon();
		});

		function fnCheckPlanMon() {
			var data = ${data};
			if(data != null) {
				alert("[" + data.plan_mon + "]월에 작성한 월 예정사항이 존재합니다.\n해당 월 예정사항 상세화면으로 이동합니다.");

				var param = {
					"plan_mon_no" : data.plan_mon_no
				};

				var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=300, left=0, top=0";
				$M.goNextPage('/mmyy/mmyy0110p01', $M.toGetParam(param), {popupStatus : popupOption});
				fnClose();
			}
		}

		// 전월예정사항
		function goDataSearch() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_year", "s_month"]}) == false) {
				return;
			}

			var sYearMonth = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_month"));
			$M.setValue("plan_mon", sYearMonth);

			var param = {
				"s_year_mon": sYearMonth
			}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							console.log(result.check_pre);
							if(result.check_pre == 'Y'){
								alert("기 작성한 / 기 작성 중인 월 예정사항이 있습니다.");
								checkPrePlanYn = "N";
								$("#total_cnt").html("0");
								AUIGrid.setGridData(auiGrid,[]);
// 								var param = {
// 									"plan_mon_no" : result.plan_mon_no
// 								};

// 								var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=300, left=0, top=0";
// 								$M.goNextPage('/mmyy/mmyy0110p01', $M.toGetParam(param), {popupStatus : popupOption});
// 								fnClose();
							}else{
								rowNo = result.total_cnt + 1;
								$("#total_cnt").html(result.total_cnt);
								AUIGrid.setGridData(auiGrid, result.list);

								checkPrePlanYn = "Y";
							}
						}
					}
			);
		}

		// 체크 후 행추가
		function fnAdd() {
			var checkGridData = AUIGrid.getCheckedRowItems(auiGrid);
			var gridData = AUIGrid.getGridData(auiGrid);

			if (checkPrePlanYn == "N") {
				alert("전월예정사항을 먼저 확인해주세요.");
				return;
			}

			if (checkGridData.length < 1 && gridData.length > 0) {
				alert("추가를 원하는 위치의 행을 먼저 체크해주세요.");
				return;
			} else {
				var rowIndex = checkGridData["length"] - 1 == -1 ? 0 : checkGridData[checkGridData["length"] - 1].rowIndex + 1;

				var item = new Object();

				item.plan_job_part = ""; // 예정업무분야
				item.plan_text = ""; // 업무예정사항
				item.share_yn = "N"; // 공유여부
				item.do_text = "" // 진행내용
				item.plan_status_name = "신규"; // 예정사항 상태명
				item.plan_status_cd = "01"; // 예정사항 상태코드
				item.extend_text = ""; // 연장내용
				item.comp_plan_dt = ""; // 완료예정일
				item.comp_text = ""; // 완료내용
				item.sort_no = rowIndex + 1;

				AUIGrid.addRow(auiGrid, item, rowIndex);

				rowNo++;
				
				for(var i=rowIndex+1;i<=gridData.length;i++){
					AUIGrid.updateRow(auiGrid,{sort_no:i+1},i);
				}
			}

			fnTotalCnt();
		}

		// 체크 후 행삭제
		function fnRemove() {
			var data = AUIGrid.getCheckedRowItems(auiGrid);
			if (data.length <= 0) {
				alert('삭제할 데이터가 없습니다.');
				return;
			}
			
			var removeRows = [];
			
			for (var i = 0; i < data.length; i++) {
				removeRows.push(data[i].rowIndex);
			}
			
			AUIGrid.removeRow(auiGrid, removeRows);
			
			var gridData = AUIGrid.getGridData(auiGrid);
			
			for(var i=0; i<gridData.length; i++){
				AUIGrid.updateRow(auiGrid,{sort_no:i+1},i);
			}
			
			fnTotalCnt();
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			         exceptColumnFields : ["sort_no","plan_status_cd"]
			  };
			fnExportExcel(auiGrid, "월 예정사항등록",exportProps);
		}

		// 작성완료
		function goProcessConfirm() {
			goSave("requestConfirm");
		}

		// 저장
		function goSave(isProcessConfirm) {
			var check = fnSetMsg(isProcessConfirm);

			if(!check){
				return ;
			}

			var data = AUIGrid.getGridData(auiGrid);
			if (data.length < 1) {
				alert("처리 할 데이터가 존재하지 않습니다.");
				return;
			}
			
			for(var i=0; i<data.length; i++){
				if(data[i].plan_status_cd == "09" && (data[i].comp_text == "" || data[i].comp_text == undefined)){
					setTimeout(function () {
                        AUIGrid.showToastMessage(auiGrid, i, 8, "완료내용을 작성해야합니다.");
                    }, 1);
					return ;
				}	
			}

			var sYearMonth = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_month"));
			$M.setValue("plan_mon", sYearMonth);

 			var gridFrm = fnGridAndFormData(auiGrid);

 			$M.goNextPageAjax(this_page + "/save", gridFrm, {method: 'POST'},
					function (result) {
						if (result.success) {
							fnClose();
							window.opener.goSearch();
						}
					}
			);
		}

		// 목록
		function fnClose() {
			window.close();
		}

		// Message Setting
		function fnSetMsg(isProcessConfirm) {
			var check = true;
			if (isProcessConfirm !== undefined) {
				check = confirm("작성완료 처리를 하시겠습니까?");
				if(check){
					$M.setValue("write_comp_yn", "Y");
					$M.setValue("modify_yn", "N");
				}
			} else {
				check = confirm("저장하시겠습니까?");
			}
			return check;
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 리스트 갯수 카운트
		function fnTotalCnt() {
			var data = AUIGrid.getGridData(auiGrid);
			$("#total_cnt").html(data.length);
		}

		// 서버로 보낼 데이터 Setting
		function fnGridAndFormData(gridObj) {
			var frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];
			var gridIds = [gridObj];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);
			
			return gridFrm;
		}

		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				showRowNumColumn: false,
				showRowCheckColumn: true,
				editable: true,
				rowStyleFunction : myStyleFunction,
                softRemoveRowMode : false,
			};

			var columnLayout = [
				{
					headerText: "No.",
					dataField: "sort_no",
					width: 50,
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "공유여부", 
					dataField : "share_yn", 
					width : "70",
					minWidth : "70", 
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				},
				{
					headerText: "업무분야",
					dataField: "plan_job_part",
					width: "80",
					minWidth: "70",
					style : "aui-center",
				},
				{
					headerText: "업무예정사항",
					dataField: "plan_text",
					width: "300",
					minWidth: "290",
					style : "aui-left",
				},
				{
					headerText: "업무내용",
					dataField: "do_text",
					width: "300",
					minWidth: "290",
					style : "aui-left",
				},
				{
					headerText: "진행사항",
					dataField: "extend_text",
					width: "300",
					minWidth: "290",
					style : "aui-left",
				},
				{
					headerText: "신규/연장",
					dataField: "plan_status_name",
					width: "70",
					minWidth: "69",
					style : "aui-center",
					editRenderer: {
                        type: "DropDownListRenderer",
                        showEditorBtn: false,
                        showEditorBtnOver: true,
                        list: planJson,
                        keyField: "code_value",
                        valueField: "code_name"
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        for (var i in planJson) {
                            if (planJson[i].code_value == item.plan_status_cd) {
                                return planJson[i].code_name;
                            }
                        }
                    }
				},
				{
					headerText: "완료예상일",
					dataField: "comp_plan_dt",
					dataType: "date",
					width: "100",
					minWidth: "65",
					style: "aui-center",
					dataInputString: "yyyymmdd",
					formatString: "yyyy-mm-dd",
					editRenderer: {
						type: "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat: "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar: false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength: 8,
						onlyNumeric: true, // 숫자만
						validator: function (oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							//삭제는 가능해야함
							if (newValue != "") {
								return fnCheckDate(oldValue, newValue, rowItem);
							}
						},
						showEditorBtnOver: true
					}
				},
				{
					headerText: "완료내용",
					dataField: "comp_text",
					width: "300",
					minWidth: "290",
					style: "aui-left"
				},
				{
					headerText: "신규/연장 상태",
					dataField: "plan_status_cd",
					visible: false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				// 신규/연장 값이 신규인 경우 연장내용은 입력 불가.
// 				if (event.item.plan_status_cd == '01') {
// 					if (event.dataField == "extend_text") {
// 						return false;
// 					}
// 				}

				// 연장인 경우 업무예정사항 입력 불가.
				if (event.item.plan_status_cd == '02') {
					if (event.dataField == "plan_text") {
						return false;
					}
				}
				
// 				if(event.item.plan_status_cd != '09'){
// 					if(event.dataField == "comp_text"){
// 						return false;
// 					}
// 				}
			});
			
			AUIGrid.bind(auiGrid, "cellEditEnd", function(event){
				if(event.dataField == "plan_status_name"){
					AUIGrid.updateRow(auiGrid,{plan_status_cd : event.value},event.rowIndex);
				}
			});
		}
		
		function myStyleFunction(rowIndex, item) {
			if (item.plan_status_cd == "01") {
				return "";
			}else if(item.plan_status_cd == "02" || item.plan_status_cd == "03"){
				return "my-blue-style";
			}else{
				return "my-gray-style";
			}
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="plan_mon" name="plan_mon"/>
	<input type="hidden" id="write_comp_yn" name="write_comp_yn" value="N"/>
	<input type="hidden" id="modify_yn" name="modify_yn" value="Y"/>
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left approval-left">
						<div class="left">
<!-- 							<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button> -->
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						</div>
					</div>
				</div>
				<!-- /상세페이지 타이틀 -->
				<div class="contents">
					<!-- 폼테이블 -->
					<div>
						<div class="title-wrap">
							<div class="left">
								<select class="form-control mr3" style="width: 70px;" id="s_year" name="s_year" required="required" alt="작성 년도" onchange="javascript:goDataSearch();">
									<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
										<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
										<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
									</c:forEach>
								</select>
								<select class="form-control" style="width: 60px;" id="s_month" name="s_month" required="required" alt="작성 월" onchange="javascript:goDataSearch();">
									<c:forEach var="i" begin="1" end="12" step="1">
										<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_month}">selected</c:if>>${i}월</option>
									</c:forEach>
								</select>
							</div>
							<div class="right dpf">
								<div>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
						<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
					</div>
					<!-- /폼테이블 -->
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>