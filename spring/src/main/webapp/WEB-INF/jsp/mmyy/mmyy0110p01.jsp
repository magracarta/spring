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
		var rowNo = ${total_cnt};
		var planJson = JSON.parse('${codeMapJsonObj['PLAN_STATUS']}');
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});

		function fnInit() {
			var writeCompYn =  "${result.write_comp_yn}";
			var secureMemNo = "${SecureUser.mem_no}";
			var memNo = "${result.reg_id}";

			// 작성완료 시 버튼 disabled 처리
			if (secureMemNo != memNo) {
				$("#_fnAdd").prop("disabled", true);
				$("#_fnRemove").prop("disabled", true);

				$("#_goProcessConfirm").addClass("dpn");
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			}else if(writeCompYn == "Y"){
				$("#_fnAdd").prop("disabled", true);
				// 작성완료시에도 삭제 가능하게 수정
// 				$("#_fnRemove").prop("disabled", true);

				$("#_goProcessConfirm").addClass("dpn");
// 				$("#_goRemove").addClass("dpn");
			}
		}

		// 체크 후 행추가
		function fnAdd() {
			var checkGridData = AUIGrid.getCheckedRowItems(auiGrid);
			var gridData = AUIGrid.getGridData(auiGrid);

			if (checkGridData.length < 1 && gridData.length > 0) {
				alert("추가를 원하는 위치의 행을 먼저 체크해주세요.");
				return;
			} else {
				rowNo++;

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
				item.seq_no = "";
				item.use_yn = "Y";
				item.cmd = "C";
				item.sort_no = rowIndex + 1;

				AUIGrid.addRow(auiGrid, item, rowIndex);
				
			}
			resetSortNo();
			fnTotalCnt();
		}

		// 체크 후 행삭제
		function fnRemove() {
			var data = AUIGrid.getCheckedRowItems(auiGrid);
			if(data.length <= 0) {
				alert("삭제할 데이터가 없습니다.");
				return;
			}

			var removeRows = [];
			var restoreRows = [];
			for (var i = 0; i < data.length; i++) {
				var isRemoved = AUIGrid.isRemovedById(auiGrid, data[i].item._$uid);
				if(isRemoved){
					restoreRows.push(data[i].rowIndex);
				}else{
					removeRows.push(data[i].rowIndex);
				}
			}
			
			for(var i = 0; i < removeRows.length; i++){
				AUIGrid.updateRow(auiGrid, { cmd : "D"}, removeRows[i]);
			}
			AUIGrid.removeRow(auiGrid, removeRows);
			AUIGrid.restoreSoftRows(auiGrid, restoreRows);
			for(var i = 0; i < restoreRows.length; i++){
				AUIGrid.updateRow(auiGrid, { cmd : "U"}, restoreRows[i]);
			}
			
			resetSortNo();
		}
		
		function resetSortNo(){
			var data = AUIGrid.getGridData(auiGrid);
			
			var sort = 1;
			for(var i = 0; i < data.length; i++){
				if(data[i].cmd != "D"){
					AUIGrid.updateRow(auiGrid, { sort_no : sort }, i);
					sort++;
				}
			}
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			         exceptColumnFields : ["use_yn","seq_no","plan_mon_no","plan_status_cd","cmd"]
			  };
			fnExportExcel(auiGrid, "월 예정사항 상세",exportProps);
		}

		// 작성완료
		function goProcessConfirm() {
			goModify("requestConfirm");
		}

		// 수정
		function goModify(isProcessConfirm) {
			var check = fnSetMsg(isProcessConfirm);

			if(!check){
				return ;
			}
			
			if(isProcessConfirm == undefined) {
				if (fnChangeGridDataCnt(auiGrid) < 1) {
					alert("수정할 데이터가 존재하지 않습니다.");
					return;
				}
			}
			
			var gridData = AUIGrid.getGridData(auiGrid);
			for(var i=0; i<gridData.length; i++){
				if(gridData[i].plan_status_cd == "09" && gridData[i].comp_text == ""){
					setTimeout(function () {
                        AUIGrid.showToastMessage(auiGrid, i, 8, "완료내용을 작성해야합니다.");
                    }, 1);
					return ;
				}	
			}

			var frm = $M.toValueForm(document.main_form);
			
			var concatCols = [];
			var concatList = [];
			concatList = concatList.concat(AUIGrid.exportToObject(auiGrid));
			concatCols = concatCols.concat(fnGetColumns(auiGrid));

			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);
			$M.goNextPageAjax(this_page + "/modify", gridFrm, {method: 'POST'},
					function (result) {
						if (result.success) {
							window.location.reload();
						}
					}
			);
		}

		// 삭제
		function goRemove() {
			var param = {
				"plan_mon_no" : $M.getValue("plan_mon_no"),
				"use_yn" : "N",
				"cmd" : "U"
			};

			$M.goNextPageAjaxMsg("해당 월의 모든 예정사항이 삭제되며,\n삭제한 월 예정사항은 복구할 수 없습니다.\n그래도 삭제하시겠습니까?", this_page + "/remove", $M.toGetParam(param), {method: 'POST'},
					function (result) {
						if (result.success) {
							fnClose();
							window.opener.goSearch();
						}
					}
			);
		}

		// 닫기
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
				check = confirm("수정 하시겠습니까?");
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

		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				showRowNumColumn: false,
				showRowCheckColumn: true,
				editable: true,
				rowStyleFunction : myStyleFunction,
			};

			// 수정여부가 N이면 editable = false, 김태공 상무님이 작성완료 상태에서도 수정 가능변경 요청하셔서 수정
// 			if($M.getValue("modify_yn") == "N") {
// 				gridPros.editable = false;
// 			}

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
					width: "60",
					minWidth: "50",
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
					width: "60",
					minWidth: "50",
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
					},
					style : "aui-center",
				},
				{
					headerText: "완료내용",
					dataField: "comp_text",
					width: "300",
					minWidth: "290",
					style : "aui-left",
				},
				{
					headerText: "월예정사항번호",
					dataField: "plan_mon_no",
					visible: false
				},
				{
					headerText: "순번",
					dataField: "seq_no",
					visible: false
				},
				{
					headerText: "사용여부",
					dataField: "use_yn",
					visible: false
				},
				{
					headerText: "신규/연장 상태",
					dataField: "plan_status_cd",
					visible: false
				},
				{
					headerText: "상태",
					dataField: "cmd",
					visible: false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				// 연장이 아닌 경우 연장내용은 입력 불가. (신규, 완료)
// 				if (event.item.plan_status_cd != '02') {
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
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="plan_mon_no" name="plan_mon_no"value="${result.plan_mon_no}"> <!-- 월예정사항번호 -->
	<input type="hidden" id="write_comp_yn" name="write_comp_yn" value="${result.write_comp_yn}"> <!-- 작성완료여부 -->
	<input type="hidden" id="modify_yn" name="modify_yn" value="${result.modify_yn}"> <!-- 수정가능여부 -->
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<div class="left approval-left">
					<h4 class="primary">월 예정사항 상세</h4>
				</div>
			</div>
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap mt5">
					<div class="left">
						<h4>[${result.plan_mon}] ${result.org_name} 계획표 <span class="text-primary">(${result.write_comp_name})</span></h4>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
			</div>
			<!-- /폼테이블-->
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