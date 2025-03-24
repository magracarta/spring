<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약출하순번관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-06-03 13:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var orderDataFieldName = []; // 발주내역 펼침 항목
		var docDataFieldName = []; // 품의내역 펼침 항목

		$(document).ready(function() {
			fnInit();
			createLeftAUIGrid();
			createRightAUIGrid();
		});
		
		function fnInit() {
			goSearchOrder();
			goSearchDoc();
		}
		
		//그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
				// rowIdField가 unique 임을 보장
				rowIdField : "_$uid",
				height : 555,
				// rowNumber
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				showStateColumn : true,
				enableFilter :true,
				editable : true
			};

			var columnLayout = [
				{
					dataField: "mch_order_out_seq",
					visible : false
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "100",
					minWidth : "80",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "생산월",
					dataField : "order_dt",
					headerStyle : "aui-fold",
					dataType : "date",
					width : "50",
					minWidth : "50",
					style : "aui-center",
					formatString : "yy-mm",
					editable : false
				},
				{
					headerText : "선적일",
					dataField : "ship_dt",
					headerStyle : "aui-fold",
					dataType : "date",
					width : "70",
					minWidth : "50",
					style : "aui-center",
					formatString : "yy-mm-dd",
					editable : false
				},
				{
					headerText : "입고일",
					dataField : "in_dt",
					dataType : "date",
					width : "70",
					minWidth : "50",
					style : "aui-center",
					formatString : "yy-mm-dd",
					editable : false
				},
				{
					headerText : "센터",
					dataField : "in_org_name",
					width : "50",
					minWidth : "50",
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (value == "" || value == undefined) {
							return "";
						} else {
							return value.substring(0, 2);
						}
					}
				},
				{
					headerText : "상태",
					dataField : "mch_status_name",
					width : "80",
					minWidth : "50",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "링크장착",
					dataField : "link_inst_dt",
					headerStyle : "aui-fold",
					dataType : "date",
					width : "80",
					minWidth : "50",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editable : true,
			        editRenderer : {
					  	type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
					  	defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
					  	onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
					  	maxlength : 8,
					  	onlyNumeric : true, // 숫자만
					  	validator : AUIGrid.commonValidator
			        }
				},
				{
					headerText : "메모",
					dataField : "remark",
					headerStyle : "aui-fold",
					width : "150",
					minWidth : "50",
					style : "aui-left aui-editable",
					editable : true
				},
			];

			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, []);

			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGridLeft);
			for (var i = 0; i < auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					orderDataFieldName.push(auiColList[i].dataField);
				}
			}

			for (var i = 0; i < orderDataFieldName.length; ++i) {
				var dataField = orderDataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGridLeft, dataField);
			}

			$("#auiGridLeft").resize();
		}

		//그리드생성
		function createRightAUIGrid() {
			var gridPros = {
				// rowIdField가 unique 임을 보장
				rowIdField : "_$uid",
				height : 555,
				// rowNumber
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				showStateColumn : true,
				enableFilter :true,
				editable : true
			};

			var columnLayout = [
				// {
				// 	dataField : "out_fix_dt",
				// 	visible : false
				// },
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "doc_mem_no",
					visible : false
				},
				{
					headerText : "출고확정",
					dataField : "out_fix_yn",
					width : "80",
					minWidth : "50",
					style : "aui-center",
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					editable : false,
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var template = "";
						if (value == "N") {
							template = '<div>';
							template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:fnDocOutProc(' + rowIndex + ',\'N\')">출고확정</span>';
							template += '</div>';
						} else {
							// template = $M.dateFormat(value, "yy-MM-dd");
							template = '<div>';
							template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:fnDocOutProc(' + rowIndex + ',\'Y\')">출고확정취소</span>';
							template += '</div>';
						}

						return template;
					}
				},
				{
					headerText : "출고확정일",
					dataField : "out_fix_dt",
					dataType : "date",
					headerStyle : "aui-fold",
					width : "80",
					minWidth : "50",
					style : "aui-center",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editable : false
				},
				{
					headerText : "출고가능일",
					dataField : "out_poss_dt",
					dataType : "date",
					width : "80",
					minWidth : "50",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editable : true,
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText : "관리번호",
					dataField : "machine_doc_no",
					width : "70",
					minWidth : "50",
					style : "aui-center aui-popup",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value.substring(4, 11);
					}
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "100",
					minWidth : "50",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "80",
					minWidth : "50",
					style : "aui-center aui-popup",
					editable : false
				},
				{
					headerText : "담당자",
					dataField : "kor_name",
					width : "80",
					minWidth : "50",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "출고희망일",
					dataField : "receive_plan_dt",
					headerStyle : "aui-fold",
					dataType : "date",
					width : "70",
					minWidth : "50",
					style : "aui-center",
					formatString : "yy-mm-dd",
					editable : false
				},
				{
					headerText : "출고예정월",
					dataField : "out_plan_mon",
					dataType : "date",
					width : "70",
					minWidth : "50",
					style : "aui-center aui-editable",
					dataInputString : "yyyymm",
					formatString : "yy-mm",
					editable : true,
					editRenderer: {
						type: "CalendarRenderer",
						defaultFormat: "yyyymm", // 달력 선택 시 데이터에 적용되는 날짜 형식
						showPlaceholder: true, // defaultFormat 설정된 값으로 플래스홀더 표시
						showEditorBtnOver: true, // 마우스 오버 시 에디터버턴 출력 여부
						onlyCalendar: false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 (기본값 : true)
						onlyMonthMode: true // 일 단위 달력이 아닌 월 단위 달력 출력
					}
				},
				{
					headerText : "메모",
					dataField : "remark",
					width : "140",
					minWidth : "50",
					style : "aui-left aui-editable",
					editable : true
				},
				{
					headerText : "전달사항",
					dataField : "order_text",
					width : "140",
					minWidth : "50",
					style : "aui-left aui-editable",
					editable : true
				},
				{
					headerText : "출고공지경과일",
					dataField : "out_count",
					width : "90",
					minWidth : "50",
					style : "aui-center",
					editable : false
				},
			];

			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);

			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGridRight);
			for (var i = 0; i < auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					docDataFieldName.push(auiColList[i].dataField);
				}
			}

			for (var i = 0; i < docDataFieldName.length; ++i) {
				var dataField = docDataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGridRight, dataField);
			}

			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
				if(event.dataField == "machine_doc_no") {
					var param = {
						"machine_doc_no" : event.item.machine_doc_no
					};
					var popupOption = "";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param), {popupStatus : popupOption});
				}

				if(event.dataField == "cust_name") {
					var param = {
						cust_no : event.item.cust_no
					}
					var poppupOption = "";
					$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});

			$("#auiGridRight").resize();
		}

		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGridRight, "계약출하순번관리 품의내역", exportProps);
		}

		function fnExcelDownSec() {
			// 엑셀 내보내기 속성
			var exportProps = {};
			fnExportExcel(auiGridLeft, "계약출하순번관리 발주내역", exportProps);
		}

		// 발주내역 조회내역 조회
		function goSearchOrder() {
			var sFromYear = $M.getValue("s_from_year");
			var sFromMon = $M.getValue("s_from_mon");
			var sToYear = $M.getValue("s_to_year");
			var sToMon = $M.getValue("s_to_mon");

			if (sFromMon.length == 1) {
				sFromMon = "0" + sFromMon;
			}

			if (sToMon.length == 1) {
				sToMon = "0" + sToMon;
			}

			var sFromYearMon = sFromYear + sFromMon;
			var sToYearMon = sToYear + sToMon;

			if ($M.toNum(sFromYearMon) > $M.toNum(sToYearMon)) {
				alert("시작일자가 종료일자보다 클 수 없습니다.");
				return false;
			}

			var param = {
				s_from_year : $M.getValue("s_from_year"),
				s_from_mon : $M.getValue("s_from_mon"),
				s_to_year : $M.getValue("s_to_year"),
				s_to_mon : $M.getValue("s_to_mon"),
				s_org_code : $M.getValue("s_org_code"),
				s_order_machine_name : $M.getValue("s_order_machine_name"),
				s_mch_status_name : $M.getValue("s_mch_status_name"),
			}

			$M.goNextPageAjax(this_page + "/order/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						$("#left_total_cnt").html(result.orderOutList.length);
						console.log("result : ", result);
						AUIGrid.setGridData(auiGridLeft, result.orderOutList);
					}
				}
			);
		}

		// 품의서 조회내역 조회
		function goSearchDoc() {
			var param = {
				s_doc_mem_name : $M.getValue("s_doc_mem_name"),
				s_cust_name : $M.getValue("s_cust_name"),
				s_doc_machine_name : $M.getValue("s_doc_machine_name")
			}

			$M.goNextPageAjax(this_page + "/doc/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						$("#right_total_cnt").html(result.docOutList.length);
						console.log("result : ", result);
						AUIGrid.setGridData(auiGridRight, result.docOutList);
					}
				}
			);
		}

		// 발주내역 저장
		function goChangeSave() {
			if (fnChangeGridDataCnt(auiGridLeft) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			if (confirm("발주내역 변경사항을 저장 하시겠습니까 ?") == false) {
				return false;
			}

			var frm = fnChangeGridDataToForm(auiGridLeft);

			$M.goNextPageAjax(this_page + "/order/save", frm, {method : 'POST'},
   				function(result) {
   					if(result.success) {
						goSearchOrder();
   					};
   				}
   			);
		}

		// 품의내역 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGridRight) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			if (confirm("품의내역 변경사항을 저장 하시겠습니까 ?") == false) {
				return false;
			}

			var frm = fnChangeGridDataToForm(auiGridRight);

			$M.goNextPageAjax(this_page + "/doc/save", frm, {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("저장이 완료되었습니다.");
							goSearchDoc();
						};
					}
			);
		}

		// 생산발주 모델 검색조건 세팅
		function goOrderOutModelInfoClick() {
			var param = {
				s_machine_name : $M.getValue("s_order_machine_name")
			};
			openSearchModelPanel('fnSetOrderOutModelInfo', 'N', $M.toGetParam(param));
		}

		function fnSetOrderOutModelInfo(result) {
			$M.setValue("s_order_machine_name", result.machine_name);
		}

		// 품의서 모델 검색조건 세팅
		function goDocOutModelInfoClick() {
			var param = {
				s_machine_name : $M.getValue("s_doc_machine_name")
			};
			openSearchModelPanel('fnSetDocOutModelInfo', 'N', $M.toGetParam(param));
		}

		function fnSetDocOutModelInfo(result) {
			$M.setValue("s_doc_machine_name", result.machine_name);
		}

		// 펼침
		function fnChangeOrderColumn(event) {
			var data = AUIGrid.getGridData(auiGridLeft);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			for (var i = 0; i < orderDataFieldName.length; ++i) {
				var dataField = orderDataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGridLeft, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGridLeft, dataField);
				}
			}
		}

		// 펼침
		function fnChangeDocColumn(event) {
			var data = AUIGrid.getGridData(auiGridRight);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			for (var i = 0; i < docDataFieldName.length; ++i) {
				var dataField = docDataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGridRight, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGridRight, dataField);
				}
			}
		}

		// 출고확정 버튼 클릭 이벤트 처리
		function fnDocOutProc(rowIndex, cancleYn) {
			var gridData = AUIGrid.getGridData(auiGridRight);
			var rowData = gridData[rowIndex];
			var machineDocNo = rowData.machine_doc_no;
			var custName = rowData.cust_name;
			var docMemNo = rowData.doc_mem_no;
			var machineName = rowData.machine_name;
			var outPossDt = rowData.out_poss_dt;

			if (machineDocNo == "" || machineDocNo == undefined) {
				alert("품의서 관리번호가 없습니다.");
				return false;
			}

			if (outPossDt == "" || outPossDt == undefined) {
				alert("출고가능일 저장 후 출고확정이 가능 합니다.");
				return false;
			}

			var msg = "";
			if (cancleYn == "N") {
				msg = "출고확정 처리 하시겠습니까 ?";
			} else {
				msg = "출고확정 취소 처리 하시겠습니까 ?";
			}

			if (confirm(msg) == false) {
				return false;
			}

			var changeCnt = fnChangeGridDataCnt(auiGridRight);
			var frm = fnChangeGridDataToForm(auiGridRight);

			if (changeCnt == 0) {
				var params = {
					"machine_doc_no" : machineDocNo,
					"cust_name" : custName,
					"doc_mem_no" : docMemNo,
					"machine_name" : machineName,
					"out_poss_dt" : outPossDt,
					"cancle_yn" : cancleYn
				}

				$M.goNextPageAjax(this_page + "/docOutProcess", $M.toGetParam(params), {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearchDoc();
						};
					}
				);
			} else {
				$M.goNextPageAjax(this_page + "/doc/save", frm, {method : 'POST', async : false},
					function(result) {
						if(result.success) {
							var params = {
								"machine_doc_no" : machineDocNo,
								"cust_name" : custName,
								"doc_mem_no" : docMemNo,
								"machine_name" : machineName,
								"out_poss_dt" : outPossDt,
								"cancle_yn" : cancleYn
							}

							$M.goNextPageAjax(this_page + "/docOutProcess", $M.toGetParam(params), {method : 'POST'},
								function(result) {
									if(result.success) {
										goSearchDoc();
									};
								}
							);
						};
					}
				);
			}
		}

		// 계약수량관리 팝업
		function goDocOutPopup() {
			var param = {}
			var poppupOption = "";
			$M.goNextPage('/sale/sale0103p01', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		function enter(fieldObj) {
			var field = ["s_order_machine_name", "s_doc_machine_name", "s_cust_name", "s_doc_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == "s_order_machine_name") {
					goOrderOutModelInfoClick();
				} else if (fieldObj.name == "s_doc_machine_name") {
					goDocOutModelInfoClick();
				} else {
					goSearchDoc(document.main_form);
				}
			});
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
								<col width="50px">
								<col width="300px">
								<col width="50px">
								<col width="150px">
								<col width="70px">
								<col width="150px">
								<col width="70px">
								<col width="200px">
							</colgroup>
							<tbody>
								<tr>
									<th>생산월</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-auto">
												<select class="form-control width120px" name="s_from_year" id="s_from_year">
													<c:forEach var="i" begin="2007" end="${inputParam.s_current_year + 5}" step="1">
														<option value="${i}" <c:if test="${i eq fn:substring(s_from_year, 0, 4)}">selected="selected"</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_from_mon" id="s_from_mon">
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="${i}" <c:if test="${i eq fn:substring(s_from_year, 5, 7)}">selected="selected"</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-auto">~</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_to_year" id="s_to_year">
													<c:forEach var="i" begin="2007" end="${inputParam.s_current_year + 5}" step="1">
														<option value="${i}" <c:if test="${i eq fn:substring(s_end_year, 0, 4)}">selected="selected"</c:if>>${i}년</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-auto">
												<select class="form-control width120px" name="s_to_mon" id="s_to_mon">
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="${i}" <c:if test="${i eq fn:substring(s_end_year, 5, 7)}">selected="selected"</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<th>상태</th>
									<td>
										<select  class="form-control" id="s_mch_status_name" name="s_mch_status_name" >
											<option value="">- 전체 -</option>
											<option value="생산">생산</option>
											<option value="선적">선적</option>
											<option value="송금예정">송금예정</option>
											<option value="송금완료">송금완료</option>
											<option value="항구대기">항구대기</option>
											<option value="항해중">항해중</option>
											<option value="즉시">즉시</option>
											<option value="24시간내">24시간내</option>
											<option value="정비후">정비후</option>
										</select>
									</td>
									<th>입고센터</th>
									<td>
										<select class="form-control" id="s_org_code" name="s_org_code"  >
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgCenterList}">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>모델</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-11">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 width140px" id="s_order_machine_name" name="s_order_machine_name" alt="모델명">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goOrderOutModelInfoClick();"><i class="material-iconssearch"></i></button>
												</div>
											</div>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 80px;" onclick="javascript:goSearchOrder()">발주내역 조회</button>
									</td>
								</tr>
							</tbody>
						</table>
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="150px">
								<col width="50px">
								<col width="150px">
								<col width="440px">
								<col width="200px">
							</colgroup>
							<tbody>
							<tr>
							<tr>
								<th>고객명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control width120px" id="s_cust_name" name="s_cust_name" alt="고객명">
									</div>
								</td>
								<th>담당자</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control width120px" id="s_doc_mem_name" name="s_doc_mem_name" alt="담당자">

									</div>
								</td>
								<th>모델</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-11">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width140px" id="s_doc_machine_name" name="s_doc_machine_name" alt="모델명">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goDocOutModelInfoClick();"><i class="material-iconssearch"></i></button>
											</div>
										</div>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 80px;" onclick="javascript:goSearchDoc()">품의서 조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<div class="row">
						<div class="col-5">
							<div class="title-wrap mt10">
								<h4>발주내역 조회결과</h4>
								<div class="btn-group">
									<div class="right">
										<label for="s_order_toggle_column" style="color:black;">
											<input type="checkbox" id="s_order_toggle_column" onclick="javascript:fnChangeOrderColumn(event)">펼침
										</label>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
									</div>
								</div>
							</div>
							<div style="margin-top: 5px; height: 555px;" id="auiGridLeft"></div>
						</div>
						<div class="col-7">
							<div class="title-wrap mt10">
								<h4>품의내역 조회결과</h4>
								<div class="btn-group">
									<div class="right">
										<label for="s_doc_toggle_column" style="color:black;">
											<input type="checkbox" id="s_doc_toggle_column" onclick="javascript:fnChangeDocColumn(event)">펼침
										</label>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div style="margin-top: 5px; height: 555px;" id="auiGridRight"></div>
						</div>
					</div>
					<div class="btn-group mt10">
						<div class="col-4">
							<div class="left">
								총 <strong id="left_total_cnt" class="text-primary">0</strong>건
							</div>
						</div>
						<div class="right" style="margin-right: 10px;">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
						</div>
						<div class="col-6">
							<div class="left">
								총 <strong id="right_total_cnt" class="text-primary">0</strong>건
							</div>
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