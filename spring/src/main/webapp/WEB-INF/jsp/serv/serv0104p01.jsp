<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 new > 상세
-- 작성자 : jsk
-- 최초 작성일 : 2024-05-23 13:31:38
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridTop;
		var auiGridBom;
		var toolCheckList = [];
		var prevToolCheckList = [];
		var centerToolBoxList = [];

		$(document).ready(function() {
			fnInit();
			fnCreateAUIGrid();
		});

		// 초기화면 세팅
		function fnInit() {
			if (${empty appr_job_seq or appr_job_seq eq 0}) {
				$("#_goApprCancel").addClass("dpn");
				$("#_goApproval").addClass("dpn");
			} else if (${apprBean.appr_proc_status_cd ne '01'}) {
				$("#_goCarryBeforeCheckTool").addClass("dpn");
				$("#_goExcelUpload").addClass("dpn");
			}

			$M.setValue("check_edit_yn", "${check_edit_yn}");
			$("#check_status_name").html("${check_status_name}");
			$("#prev_check_status_name").html("${prev_check_status_name}");

			centerToolBoxList = ${not empty center_tool_box_list? center_tool_box_list : []};
			toolCheckList = ${not empty tool_check_list? tool_check_list : []};
			prevToolCheckList = ${not empty prev_tool_check_list? prev_tool_check_list : []};

			fnCreateAUIGrid();
		}

		// 그리드 초기화 후 생성
		function fnCreateAUIGrid() {
			AUIGrid.setGridData(auiGridTop, []);
			AUIGrid.setGridData(auiGridBom, []);
			AUIGrid.destroy("#auiGridTop");
			AUIGrid.destroy("#auiGridBom");
			auiGridTop = null;
			auiGridBom = null;

			createAUIGridTop();
			createAUIGridBom();
			fnSyncAUIGridScroll(auiGridTop, auiGridBom, "Y", "Y");		//그리드 동기화
		}

		// 센터 변경
		function fnChangeCenterCode(isCreateGrid) {
			var param = {
				"center_org_code": $M.getValue("s_center_org_code")
			}
			$M.goNextPageAjax(this_page + "/search/center", $M.toGetParam(param), {method : 'GET'},
					function(result) {
						if(result.success) {
							$("#s_nsvc_tool_check_seq option").remove();
							if ( result.list != "" && result.list != undefined ) {
								for(i = 0; i< result.list.length; i++){
									var optVal = result.list[i].nsvc_tool_check_seq;
									var optText = result.list[i].check_dt + " " + result.list[i].appr_proc_status_name;

									$('#s_nsvc_tool_check_seq').append('<option value="'+ optVal +'"' + (i==0? 'selected="selected"': '') +'>'+ optText +'</option>');
								}
							}
							centerToolBoxList = result.center_tool_box_list;

							if (isCreateGrid !== false) {
								fnCreateAUIGrid();
								AUIGrid.setGridData(auiGridTop, []);
								AUIGrid.setGridData(auiGridBom, []);
							}
						}
					}
			);
		}

		// 화면 reload
		function fnReload(value) {
			var param = {
				"s_nsvc_tool_check_seq": value == undefined? $M.getValue("s_nsvc_tool_check_seq") : value,
				"s_center_org_code": $M.getValue("s_center_org_code")
			}
			$M.goNextPage("/serv/serv0104p01", $M.toGetParam(param), {popupStatus : ""});
		}

		//그리드생성
		function createAUIGridTop() {
			var gridPros = {
				editable : true,
				rowIdField : "_$uid",
				rowIdTrustMode : true,
				showRowNumColumn: true,
				showStateColumn: true
			};
			var columnLayout = [
				{
					dataField : "nsvc_tool_check_seq",
					visible : false
				},
				{
					dataField : "svc_tool_seq",
					visible : false
				},
				{
					dataField : "cmd",
					visible : false
				},
				{
					headerText : "공구이름",
					dataField : "tool_name",
					style : "aui-left",
					width : "20%",
					editable : false
				},
				{
					headerText : "이전수량",
					dataField : "before_check_qty_sum",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					width : "8%",
					editable : false
				},
				{
					headerText : "조사수량",
					dataField : "check_qty_sum",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					width : "8%",
					editable : false
				},
				{
					headerText : "차이수량",
					dataField : "gap_qty_sum",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					width : "8%",
					editable : false
				},
				{
					headerText : "차이발생이유",
					dataField : "gap_remark",
					style : "aui-left  aui-editable",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 100,
						validator : AUIGrid.commonValidator
					}
				}
			];

			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			if($M.getValue("check_edit_yn") == "Y") {
				for (var i = 0; i < centerToolBoxList.length; ++i) {
					var result = centerToolBoxList[i];
					var columnObj = {
						headerText : result.box_name,
						dataField : "box" + result.nsvc_tool_box_seq + "_cnt",
						style : "aui-center aui-editable",
						width : "8%",
						editable : true,
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
							return value == "" ? 0 : AUIGrid.formatNumber(value, "#,##0");
						},
						editRenderer : {
							onlyNumeric : true,
							allowPoint : false
						}
					}
					AUIGrid.addColumn(auiGridTop, columnObj, 'last');
				}
			} else {
				for (var i = 0; i < centerToolBoxList.length; ++i) {
					var result = centerToolBoxList[i];
					var columnObj = {
						headerText : result.box_name,
						dataField : "box" + result.nsvc_tool_box_seq + "_cnt",
						style : "aui-center",
						dataType: "numeric",
						formatString: "#,##0",
						width : "8%",
						editable : false,
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
							return value == "" ? 0 : AUIGrid.formatNumber(value, "#,##0");
						}
					}
					AUIGrid.addColumn(auiGridTop, columnObj, 'last');
				}
			}

			AUIGrid.bind(auiGridTop, "cellEditBegin", function( event ) {
				if(event.dataField == "gap_remark") {
					if($M.getValue("check_edit_yn") == "Y"){
						// 차이수량이 0아닌 경우에만 에디팅허용
						if(event.item.gap_qty_sum != 0) {
							return true;
						} else {
							return false;
						}
					} else {
						//결제요청, 결제완료시 실사수량 수정 불가
						return false;
					}
				}
			});

			AUIGrid.bind(auiGridTop, "cellEditEnd", function( event ) {
				//공구함별 공구의 재고 변경시 조사수량 , 차이수량 변경하기
				if(event.dataField.endsWith("_cnt")) {
					//수량이 변결될때만
					if ( event.value != event.oldValue ) {
						var checkQty = 0;
						var beforeCheckQty = Number($M.nvl(event.item.before_check_qty_sum, 0));

						var keys = Object.keys(event.item);
						keys.forEach(key => {
							if (key.endsWith("_cnt")) {
								checkQty += Number($M.nvl(event.item[key], 0));
							}
						});
						// 조사수량,차이수량 갱신
						AUIGrid.updateRow(auiGridTop, { "check_qty_sum" : checkQty }, event.rowIndex );
						AUIGrid.updateRow(auiGridTop, { "gap_qty_sum"   : checkQty - beforeCheckQty }, event.rowIndex );
					}
				}
			});

			AUIGrid.setGridData(auiGridTop, toolCheckList);
			$("#auiGridTop").resize();
		}

		//그리드생성
		function createAUIGridBom() {
			var gridPros = {
				editable : false,
				rowIdField : "_$uid",
				showRowNumColumn: true
			};
			var columnLayout = [
				{
					dataField : "nsvc_tool_check_seq",
					visible : false
				},
				{
					dataField : "svc_tool_seq",
					visible : false
				},
				{
					dataField : "cmd",
					visible : false
				},
				{
					headerText : "공구이름",
					dataField : "tool_name",
					style : "aui-left",
					width : "20%"
				},
				{
					headerText : "이전수량",
					dataField : "before_check_qty_sum",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					width : "8%"
				},
				{
					headerText : "조사수량",
					dataField : "check_qty_sum",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					width : "8%"
				},
				{
					headerText : "차이수량",
					dataField : "gap_qty_sum",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					width : "8%"
				},
				{
					headerText : "차이발생이유",
					dataField : "gap_remark",
					style : "aui-left"
				}
			];

			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			for (var i = 0; i < centerToolBoxList.length; ++i) {
				var result = centerToolBoxList[i];
				var columnObj = {
					headerText : result.box_name,
					dataField : "box" + result.nsvc_tool_box_seq + "_cnt",
					style : "aui-center",
					dataType: "numeric",
					formatString: "#,##0",
					width : "8%",
					editable : false,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" ? 0 : AUIGrid.formatNumber(value, "#,##0");
					}
				}

				AUIGrid.addColumn(auiGridBom, columnObj, 'last');
			}
			AUIGrid.setGridData(auiGridBom, prevToolCheckList);
			$("#auiGridBom").resize();
		}

		// 조회
		function goSearch() {
			fnReload();
			// $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
			// 		function(result) {
			// 			if(result.success) {
			// 				$M.setValue("check_edit_yn", result.check_edit_yn);
			// 				$("#check_status_name").html(result.check_status_name);
			// 				$("#prev_check_status_name").html(result.prev_check_status_name);
			//
			// 				fnCreateAUIGrid();
			// 				AUIGrid.setGridData(auiGridTop, result.tool_check_list);
			// 				AUIGrid.setGridData(auiGridBom, result.prev_tool_check_list);
			// 			}
			// 		}
			// );
		}

		// 결재요청
		function goRequestApproval() {
			$M.setValue("save_mode", "appr");
			goSave('requestAppr');
		}

		// 결재처리
		function goApproval() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}"
			};
			$M.setValue("save_mode", "approval"); // 승인
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}

		// 결재처리 결과
		function goApprovalResult(result) {
			// 반려이면 페이지 리로딩
			if (result.appr_status_cd == '03') {
				$M.goNextPageAjax('/session/check', '', {method: 'GET'},
						function (result) {
							if (result.success) {
								alert("반려가 완료되었습니다.");
								location.reload();
							}
						}
				);
			} else if (result.appr_status_cd == '04') {
				$M.goNextPageAjax('/session/check', '', {method : 'GET'},
						function(result) {
							if(result.success) {
								alert("결재취소가 완료됐습니다.");
								location.reload();
							}
						}
				);
			} else {
				$M.goNextPageAjax('/session/check', '', {method : 'GET'},
						function(result) {
							if(result.success) {
								location.reload();
							}
						}
				);
			}
		}

		// 저장
		function goSave(isRequestAppr) {
			if($M.getValue("s_center_org_code") == ""){
				alert("센터를 선택해 주세요");
				return false;
			}
			if (centerToolBoxList == null || centerToolBoxList.length == 0) {
				alert("공구함이 존재하지 않습니다. 확인 후 진행해주세요.");
				return false;
			}
			var editedRows = AUIGrid.getEditedRowItems(auiGridTop);
			for (var i = 0; i < editedRows.length; i++) {
				var row = editedRows[i];
				if( $M.nvl(row.gap_qty_sum, 0) != 0 && row.gap_remark == '' ) {
					var rowIndex = AUIGrid.rowIdToIndex(auiGridTop, row._$uid);
					AUIGrid.showToastMessage(auiGridTop, rowIndex, 7, "차이수량이 있는경우 차이발생이유 값은 필수값입니다.");
					return;
				}
			}

			var msg = "";
			if (isRequestAppr != undefined) {
				// 결재처리
				if (isRequestAppr == "approval") {
					$M.setValue("save_mode", "approval"); // 승인
				} else {
					// 결재요청
					$M.setValue("save_mode", "appr"); // 결재요청
					msg = "결재 후 수정이 제한됩니다.\n계속 진행하시겠습니까?";
				}
			} else {
				if(editedRows.length < 1 ){
					alert("변경된 데이터가 없습니다.");
					return false;
				}
				$M.setValue("save_mode", "save"); // 저장
				msg = "저장 하시겠습니까?";
			}

			if (msg != "" && confirm(msg) == false) {
				return false;
			}

			// 공구실사 상세내역 세팅
			// var gridForm = fnChangeGridDataToForm(auiGridTop);
			// $M.copyForm(gridForm, frm);
			// fnChangeGridDataToForm 속도이슈로 form에 _str set

			var checkMemNo = "${SecureUser.mem_no}";

			var nsvcToolCheckSeqArr = [];
			var svcToolSeqArr = [];
			var checkQtySumArr = [];
			var beforeCheckQtySumArr = [];
			var gapRemarkArr = [];

			var nsvcToolCheckSeqDtlArr = [];
			var svcToolSeqDtlArr = [];
			var nsvcToolBoxSeqDtlArr = [];
			var checkQtyDtlArr = [];
			var checkMemNoDtlArr = [];

			for (i = 0; i<editedRows.length; i++) {
				var item = editedRows[i];
				nsvcToolCheckSeqArr.push($M.nvl(item.nsvc_tool_check_seq, "0"));
				svcToolSeqArr.push($M.nvl(item.svc_tool_seq, "0"));
				checkQtySumArr.push($M.nvl(item.check_qty_sum, "0"));
				beforeCheckQtySumArr.push($M.nvl(item.before_check_qty_sum, "0"));
				gapRemarkArr.push($M.nvl(item.gap_remark, ""));

				for (j = 0; j<centerToolBoxList.length; j++) {
					nsvcToolCheckSeqDtlArr.push($M.nvl(item.nsvc_tool_check_seq, "0"));
					svcToolSeqDtlArr.push($M.nvl(item.svc_tool_seq, "0"));
					nsvcToolBoxSeqDtlArr.push($M.nvl(centerToolBoxList[j].nsvc_tool_box_seq, "0"));
					checkMemNoDtlArr.push(checkMemNo);
					var colName = "box" + centerToolBoxList[j].nsvc_tool_box_seq + "_cnt";
					checkQtyDtlArr.push($M.nvl(item[colName], "0"));
				}
			}

			var frm = $M.toValueForm(document.main_form);
			var option = { isEmpty : true };
			$M.setHiddenValue(frm, "nsvc_tool_check_seq_str", $M.getArrStr(nsvcToolCheckSeqArr, option));
			$M.setHiddenValue(frm, "svc_tool_seq_str", $M.getArrStr(svcToolSeqArr, option));
			$M.setHiddenValue(frm, "check_qty_sum_str", $M.getArrStr(checkQtySumArr, option));
			$M.setHiddenValue(frm, "before_check_qty_sum_str", $M.getArrStr(beforeCheckQtySumArr, option));
			$M.setHiddenValue(frm, "gap_remark_str", $M.getArrStr(gapRemarkArr, option));
			$M.setHiddenValue(frm, "dtl_nsvc_tool_check_seq_str", $M.getArrStr(nsvcToolCheckSeqDtlArr, option));
			$M.setHiddenValue(frm, "dtl_svc_tool_seq_str", $M.getArrStr(svcToolSeqDtlArr, option));
			$M.setHiddenValue(frm, "dtl_nsvc_tool_box_seq_str", $M.getArrStr(nsvcToolBoxSeqDtlArr, option));
			$M.setHiddenValue(frm, "dtl_check_qty_str", $M.getArrStr(checkQtyDtlArr, option));
			$M.setHiddenValue(frm, "dtl_check_mem_no_str", $M.getArrStr(checkMemNoDtlArr, option));

			// 저장요청
			$M.goNextPageAjax(this_page + "/save", frm , {method: "POST"},
					function (result) {
						if (result.success) {
							fnReload();
							window.opener.goSearch();
						}
					}
			);
		}

		// 조사일자추가
		function goAddToolCheckDt() {
			if($M.getValue("s_center_org_code") == ""){
				alert("센터를 선택해 주세요");
				return false;
			}
			var param = {
				"center_org_code": $M.getValue("s_center_org_code")
			};
			var msg = "조사일자를 추가하시겠습니까?"
			$M.goNextPageAjaxMsg(msg, this_page + "/insertSvcToolCheck", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							$M.setValue("s_nsvc_tool_check_seq", result.nsvc_tool_check_seq);
							fnReload(result.nsvc_tool_check_seq);
						}
					}
			);
		}

		// 이전수량 이월
		function goCarryBeforeCheckTool() {
			if($M.getValue("s_center_org_code") == ""){
				alert("센터를 선택해 주세요");
				return false;
			}
			if($M.getValue("s_nsvc_tool_check_seq") == ""){
				alert("조사일자목록을 선택해 주세요.");
				return false;
			}

			var param = {
				"s_center_org_code": $M.getValue("s_center_org_code"),
				"s_nsvc_tool_check_seq": $M.getValue("s_nsvc_tool_check_seq")
			};
			var msg = "결재요청 또는 완료건 중 가장 최신건이 이월됩니다. \r\n진행하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/carryBeforeToolCheck", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							// 조사일자 목록 조회
							fnChangeCenterCode();
							// 그리드 재조회
							goSearch();
						}
					}
			);
		}

		// 공구함관리
		function goToolBoxMngPopup() {
			if($M.getValue("s_center_org_code") == ""){
				alert("센터를 선택해 주세요");
				return false;
			}
			var param = {
				"parent_js_name": "goSearch",
				"center_org_code": $M.getValue("s_center_org_code")
			};
			$M.goNextPage('/serv/serv0104p02', $M.toGetParam(param), {popupStatus : getPopupProp(1300, 780)});
		}

		// 공구관리
		function goToolMngPopup() {
			var param = {
				"parent_js_name": "goSearch"
			};
			$M.goNextPage('/serv/serv0104p03', $M.toGetParam(param), {popupStatus : getPopupProp(1000, 520)});
		}

		// 엑셀업로드
		function goExcelUpload() {
			if($M.getValue("s_center_org_code") == ""){
				alert("센터를 선택해 주세요");
				return false;
			}
			if($M.getValue("s_nsvc_tool_check_seq") == ""){
				alert("조사일자목록을 선택해 주세요.");
				return false;
			}
			if (centerToolBoxList == null || centerToolBoxList.length == 0) {
				alert("공구함이 존재하지 않습니다. 확인 후 진행해주세요.");
				return false;
			}
			var param = {
				"s_center_org_code": $M.getValue("s_center_org_code"),
				"s_nsvc_tool_check_seq": $M.getValue("s_nsvc_tool_check_seq"),
				"parent_js_name": "setExcelData"
			};
			$M.goNextPage('/serv/serv0104p04', $M.toGetParam(param), {popupStatus: {}});
		}

		// 엑셀 데이터 세팅
		function setExcelData(data) {
			$M.setValue("s_center_org_code", data.center_org_code);
			fnChangeCenterCode(false);

			// 조회조건 세팅 후 진행
			setTimeout(function() {
				$M.setValue("s_nsvc_tool_check_seq", data.nsvc_tool_check_seq);

				var dataList = data.list;
				for (var i=0; i<toolCheckList.length; i++) {
					var setYn = false;
					for (var j=0; j<dataList.length; j++) {
						if (toolCheckList[i].tool_name === dataList[j].tool_name) {
							setYn = true;
							AUIGrid.updateRow(auiGridTop, Object.assign(toolCheckList[i], dataList[j]), i);
							break;
						}
					}
					if (setYn === false) {
						var defaultItem = toolCheckList[i];
						defaultItem.before_check_qty_sum = 0;
						defaultItem.check_qty_sum = 0;
						defaultItem.gap_qty_sum = 0;
						defaultItem.gap_remark = "";
						for (var k= 0; k < centerToolBoxList.length; k++) {
							defaultItem["box"+ centerToolBoxList[k].nsvc_tool_box_seq + "_cnt"] = 0;
						}
						AUIGrid.updateRow(auiGridTop, defaultItem, i);
					}
				}
			}, 1000);
		}

		// 작성중 문서 삭제 기능
		function goRemove() {
			if($M.getValue("s_center_org_code") == ""){
				alert("센터를 선택해 주세요");
				return false;
			}
			if($M.getValue("s_nsvc_tool_check_seq") == ""){
				alert("조사일자목록을 선택해 주세요.");
				return false;
			}

			if (confirm("삭제하시겠습니까?") == false) {
				return false;
			}

			var param = {
				"nsvc_tool_check_seq": $M.getValue("s_nsvc_tool_check_seq"),
			};
			$M.goNextPageAjax(this_page + "/remove", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							fnClose();
							window.opener.goSearch();
						}
					}
			);
		}

		// 결재반려
		function goApprCancel() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				appr_cancel_yn : "Y"
			};
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}

		// 엑셀다운로드
		function fnExcelDownload() {
			var exportProps = {
				// 제외항목
				exceptColumnFields : ["nsvc_tool_check_seq", "svc_tool_seq", "cmd"]
			};
			fnExportExcel(auiGridTop, "정비Tool관리", exportProps);
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="check_edit_yn" 	name="check_edit_yn" value="N" />
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->

		<div class="content-wrap">
			<div class="title-wrap mt10">
				<div class="left approval-left">
					<h4 class="primary">정비Tool관리 상세</h4>
				</div>
				<!-- 결재영역 -->
				<div class="pl10">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
				<!-- /결재영역 -->
			</div>
			<div class="search-wrap mt10">
				<table class="table">
					<colgroup>
						<col width="50px">
						<col width="100px">
						<col width="90px">
						<col width="180px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>센터</th>
						<td>
							<c:if test="${center_auth_yn ne 'Y'}">
								<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
								<input type="hidden" value="${SecureUser.org_code}" id="s_center_org_code" name="s_center_org_code" readonly="readonly">
							</c:if>
							<c:if test="${center_auth_yn eq 'Y'}">
								<select class="form-control" id="s_center_org_code" name="s_center_org_code" onchange="javascript:fnChangeCenterCode();">
									<option value="">- 전체 -</option>
									<c:forEach var="item" items="${orgCenterList}">
										<option value="${item.org_code}" <c:if test="${item.org_code eq inputParam.s_center_org_code}">selected="selected"</c:if>>${item.org_name}</option>
									</c:forEach>
								</select>
							</c:if>
						</td>
						<th>조사일자목록</th>
						<td>
							<select class="form-control" id="s_nsvc_tool_check_seq" name="s_nsvc_tool_check_seq" onchange="javascript:fnReload(this.value);">
								<c:forEach var="item" items="${center_check_dt_list}">
									<option value="${item.nsvc_tool_check_seq}" <c:if test="${item.nsvc_tool_check_seq eq inputParam.s_nsvc_tool_check_seq}">selected="selected"</c:if>>${item.check_dt} ${item.appr_proc_status_name}</option>
								</c:forEach>
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
			<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4><span id="check_status_name" name="check_status_name"></span></h4>
				<div class="btn-group">
					<div class="right">
						<input type="file" name="file_comp" id="fileSelector" style="display:none;width:5px;" accept=".xlsx" >
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
			<div id="auiGridTop" style="margin-top: 5px; height: 300px;"></div>

			<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4><span id="prev_check_status_name" name="prev_check_status_name" ></span></h4>
			</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
			<div id="auiGridBom" style="margin-top: 5px; height: 300px;"></div>

			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
						<jsp:param name="appr_yn" value="${(empty appr_job_seq or appr_job_seq eq 0) ? 'N' : 'Y'}"/>
					</jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>