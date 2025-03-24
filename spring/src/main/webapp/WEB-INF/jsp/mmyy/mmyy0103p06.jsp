<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지(일반) > 업무일지 상세(서비스부)
-- 작성자 : 박동훈
-- 최초 작성일 : 2024-12-12 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style type="text/css">
		/* 커스텀 행 스타일 (비활성화) */
		.my-row-style-disable {
			text-align:left;
			background-color: #E9ECEF;
		}
	</style>
	<script type="text/javascript">
		var auiGrid;
		var orgCode = "${s_org_code}";
		var workDt = "${s_work_dt}";

		var auiGridBottom; //업무내용상세

		var isLoading = false;

		//예약건 갯수
		var repairReCnt = 0;
		// 업무일지 텍스트에 들어갈 내용
		// var work_text ="";

		$(document).ready(function() {
			createAUIGrid();
			createAUIGridBottom();

			//완료버튼 유무
			if("${bean.complete_yn}" != "Y"){
				$("#_goComplete").show();
				$("#_fnCancel").hide();
			}else {
				$("#_goComplete").hide();
				$("#_fnCancel").show();
				$("#goEtcSaveBtn").prop("disabled",true);
			}

			if("${inputParam.mng_yn}" == "Y"){
				$("#_goComplete").hide();
				$("#_fnCancel").hide();
			}
		});

		function fnSelectDay(sWorkDt){
			$M.setValue("s_work_dt",sWorkDt);
			goSearch();
		}

		// 정비예약가능 버튼 노출 세팅
		function fnSetResvAvleBtn() {
			// 고객앱 조회일자에 정비예약가능여부에 따라 버튼노출여부 설정
			if ($M.getValue("am_resv_able_yn") == "Y") {
				$("#_goAmResvAble").hide();
				$("#_goAmResvNotAble").show();
			} else if ($M.getValue("am_resv_able_yn") == "N") {
				$("#_goAmResvAble").show();
				$("#_goAmResvNotAble").hide();
			} else {
				$("#_goAmResvAble").hide();
				$("#_goAmResvNotAble").hide();
			}
            if ($M.getValue("pm_resv_able_yn") == "Y") {
				$("#_goPmResvAble").hide();
				$("#_goPmResvNotAble").show();
			} else if ($M.getValue("pm_resv_able_yn") == "N") {
				$("#_goPmResvAble").show();
				$("#_goPmResvNotAble").hide();
            } else {
				$("#_goPmResvAble").hide();
				$("#_goPmResvNotAble").hide();
			}
			fnShowResvState();
		}

		// 조회
		function goSearch(s_org_code, s_work_dt) {
			if (s_org_code != undefined) {
				$M.setValue("s_org_code", s_org_code);
			}
			if (s_work_dt != undefined) {
				$M.setValue("s_work_dt", s_work_dt);
			}

			if($M.getValue("s_work_dt")==""){
				alert("조회일자는 필수입력입니다.");
				return false;
			}

			if($M.getValue("s_org_code")==""){
				alert("센터는 필수선택입니다.");
				return false;
			}

			var param = {
				"s_work_dt" : $M.getValue("s_work_dt"),
				"s_org_code" : $M.getValue("s_org_code"),
				"s_mem_no" : "${inputParam.s_mem_no}"
			};
			$M.goNextPage(this_page, $M.toGetParam(param));
		}

		function goEtcSave(){
			if($M.getValue("work_st_ti")==""){
				alert("시간 선택은 필수입니다.");
				return false;
			}

			if($M.getValue("remark")==""){
				alert("업무내용을 작성해 주세요.");
				return false;
			}

			if($M.getValue("s_mem_no")!="${inputParam.s_mem_no}"){
				alert("본인내용만 수정 가능합니다.");
				return false;
			}

			var param = {
				"s_work_dt" : $M.getValue("s_work_dt"),
				"s_org_code" : $M.getValue("s_org_code"),
				"work_st_ti" : $M.getValue("work_st_ti"),
				"day_board_seq" : $M.getValue("day_board_seq"),
				"work_ed_ti" : $M.getValue("work_st_ti").substring(0,2)+"59",
				"remark" : $M.getValue("remark"),
				"s_mem_no" : $M.getValue("s_mem_no"),
			};

			var msg = "업무 내용을 저장 하시겠습니까?";
			$M.goNextPageAjaxMsg(msg,this_page + "/workEtcSave", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
							goSearch();
						}
					}
			);
		}

		function goEtcDel(){

			if($M.getValue("s_mem_no")!="${inputParam.s_mem_no}"){
				alert("본인내용만 삭제 가능합니다.");
				return false;
			}

			var param = {
				"s_work_dt" : $M.getValue("s_work_dt"),
				"day_board_seq" : $M.getValue("day_board_seq"),
				"s_mem_no" : $M.getValue("s_mem_no"),
				"remark" : $M.getValue("remark"),
				"use_yn" : "N"
			};

			var msg = "업무 내용을 삭제 하시겠습니까?";
			$M.goNextPageAjaxMsg(msg,this_page + "/workEtcSave", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
							goSearch();
						}
					}
			);
		}

		// 예약불가로 상태 변경
		function goAmResvNotAble() {
			var param = {
				"am_yn": "N",
				"apm_gubun": "A",
			}
			goChangeAbleResv(param, 'N');
		}

		// 예약가능으로 상태 변경
		function goAmResvAble() {
			var param = {
				"am_yn": "Y",
				"apm_gubun": "A",
			}
			goChangeAbleResv(param, 'Y');
		}

		// 예약불가로 상태 변경
		function goPmResvNotAble() {
			var param = {
				"pm_yn": "N",
				"apm_gubun": "P",
			}
			goChangeAbleResv(param, 'N');
		}

		// 예약가능으로 상태 변경
		function goPmResvAble() {
			var param = {
				"pm_yn": "Y",
				"apm_gubun": "P",
			}
			goChangeAbleResv(param, 'Y');
		}

		// 예약가능상태 변경
		function goChangeAbleResv(param, ableYn) {
			param.not_dt = workDt;
			param.org_code = orgCode;

			var msg = "고객앱의 " + $M.dateFormat(workDt, "yyyy-MM-dd") + " 날짜에 ";
			msg += param.apm_gubun == 'A' ? "오전" : "오후";
			if(ableYn == "N") {
				msg += " 예약 불가";
			} else {
				msg += " 예약가능";
			}
			msg += " 상태로 변경하시겠습니까?"

			$M.goNextPageAjaxMsg(msg, "/mmyy/mmyy0113/resv", $M.toGetParam(param), {method : 'post'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
							if(param.apm_gubun == "A") {
								$M.setValue("am_resv_able_yn", ableYn);
							} else {
								$M.setValue("pm_resv_able_yn", ableYn);
							}
							fnSetResvAvleBtn();
						}
					}
			);
		}

		// 그리드 생성
		function createAUIGrid() {

			// 버튼 노출 세팅
			$M.setValue("am_resv_able_yn", "${info.am_resv_able_yn}");
			$M.setValue("pm_resv_able_yn", "${info.pm_resv_able_yn}");
			fnSetResvAvleBtn();

			// 정비신청/렌탈출고/렌탈회수 미지정건
			$("#not_ref_cnt").text("${info.not_ref_cnt}");

			// 조회결과
			var gridPros = {
				rowIdField : "day_board_time_cd",
				showRowNumColumn: false,
				useGroupingPanel : false,
				showBranchOnGrouping : false,
				enableCellMerge : true,
				cellMergeRowSpan:  true,
				rowSelectionWithMerge : true,
				fixedColumnCount : 1,
				editable : false,
				wordWrap: true
			};

			var columnLayout = [
				{
					headerText : "시간",
					dataField : "day_board_time_name",
					width : "80",
					minWidth : "20",
					style : "aui-center",
					renderer: {
						type: "IconRenderer",
						iconPosition: "aisleRight", // 아이콘 위치
						iconWidth: 16, // icon 사이즈, 지정하지 않으면 rowHeight에 맞게 기본값 적용됨
						iconHeight: 16,
						iconTableRef: { // icon 값 참조할 테이블 레퍼런스
							"default": "/static/easyui/themes/icons/plus_icon.png" // default
						},
						onClick: function (event) {
							if("${inputParam.mng_yn}" != "Y"){
								$M.setValue("remark","");
								$M.setValue("day_board_seq","");
								$M.setValue("s_mem_no","${inputParam.s_mem_no}");
								$M.setValue("work_st_ti",event.item.day_board_time_cd);
								if("${bean.complete_yn}" != "Y"){
									$("#remark").prop("disabled", false);
								}
								$("#remark").focus();
								$("#goEtcDelBtn").hide();
							}
						},
					},
				},
				{
					dataField : "day_board_time_cd",
					visible : false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			var memList = ${mem_list};
			AUIGrid.setGridData(auiGrid, []);
			if (memList != null && memList.length > 0) {
				for (var i = 0; i < memList.length; ++i) {
					var row = memList[i];
					var memNo = row.mem_no
					var memNoFieldName = "a_" + memNo;
					var headerTextName = row.mem_name;
					var dataFieldName = memNo + "_content";
					var seqStrFieldName = memNo + "_day_doc_no_str";
					var columnObj = [
						{
							headerText: headerTextName,
							dataField: dataFieldName,
							width: "17%",
							editable : false,
							renderer : {
								type : "TemplateRenderer"
							},
							cellMerge : true,
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								var ret = "aui-left";
								var tempMemNo = dataField.split("_")[0];
								var disableYn = item[tempMemNo + "_disable_yn"];
								if (disableYn == "Y") {
									ret = "my-row-style-disable";
								}
								return ret;
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
								var tempMemNo = dataField.split("_")[0];

								var daySeqStr = item[tempMemNo + "_day_doc_no_str"];
								var template = "";
								if (daySeqStr != null && daySeqStr != "" && daySeqStr != undefined) {
									template = '<div class="aui-grid-renderer-base" style="overflow: hidden; white-space: nowrap; width: 100%;">';
									var innerTemplate = '';
									var seqArr = daySeqStr.split("#");
									for (var i=0; i<seqArr.length; i++) {
										var content = item[tempMemNo + "_" + seqArr[i].replaceAll('%%', '') + "_content"];
										if (content != null && content != "" && content != undefined) {
											var jobDiv = item[tempMemNo + "_" + seqArr[i].replaceAll('%%', '') + "_div"];
											var jobDivNm = item[tempMemNo + "_" + seqArr[i].replaceAll('%%', '') + "_div_nm"];
											var ti_div = item[tempMemNo + "_" + seqArr[i].replaceAll('%%', '') + "_ti_div"];
											var cust_no = item[tempMemNo + "_" + seqArr[i].replaceAll('%%', '') + "_cust_no"];
											var machine_name = item[tempMemNo + "_" + seqArr[i].replaceAll('%%', '') + "_machine_name"];
											innerTemplate = innerTemplate==''? '' : innerTemplate + '<br>';
											var underlineText = ${inputParam.s_popup_yn eq 'Y'}? "" : "text-decoration: underline;";
											innerTemplate += '<span style="';
											if(jobDivNm == "정비"){
												innerTemplate += 'color:blue; ';
											}else if(jobDivNm == "정비예약"){
												innerTemplate += 'color:green; ';
											}
											innerTemplate += 'cursor: pointer; ' +underlineText+ ' " title="'+ content +'" onclick="javascript:goDetailDayJobPop(\''+ tempMemNo +'\',\''+ seqArr[i] +'\', \'' + jobDiv + '\', \'' + cust_no + '\', \'' + machine_name + '\');">'+ content;
											if(ti_div == "ed" && jobDiv != "etc"){
												innerTemplate += '<img src="/static/easyui/themes/icons/e_icon.png" style="margin-left: 3px; height:20px;">';
											}else if(ti_div == "st" && jobDiv != "etc"){
												innerTemplate += '<img src="/static/easyui/themes/icons/s_icon.png" style="margin-left: 3px; height:20px;">';
											}
											innerTemplate +='</span>';
										}
									}
									template += innerTemplate ;
									template += '</div>';
								}
								return template;
							},
						},
						{
							dataField: memNoFieldName,
							visible: false
						},
						{
							dataField: seqStrFieldName,
							visible: false
						},
					];

					AUIGrid.addColumn(auiGrid, columnObj, 'last');
				}
			}

			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			// 일지완료시 정비예약건 갯수와 일지에 들어갈 일정 정리
			var listArray = ${list};
			for(var i =0 ; i < listArray.length; i++){
				var memNo = "${SecureUser.mem_no}";
				if(listArray[i][memNo + "_day_doc_no_str"] != "" && listArray[i][memNo + "_day_doc_no_str"] != undefined){
					var seqArr = listArray[i][memNo + "_day_doc_no_str"].split("#");
					for (var j=0; j<seqArr.length; j++) {
						var content = listArray[i][memNo + "_" + seqArr[j].replaceAll('%%', '') + "_content"];
						if (content != null && content != "" && content != undefined) {
							var jobDiv =  listArray[i][memNo + "_" + seqArr[j].replaceAll('%%', '') + "_div"];
							var jobDivNm =  listArray[i][memNo + "_" + seqArr[j].replaceAll('%%', '') + "_div_nm"];
							var ti_div =  listArray[i][memNo + "_" + seqArr[j].replaceAll('%%', '') + "_ti_div"];

							if(ti_div == "st"){
								//정비예약 시작이 있을 시 미완료건 +1
								if(jobDivNm == "정비예약"){
									repairReCnt ++;
								}
								// 업무일지에 들어갈 텍스트
								// work_text += content + "#";
							}
						}
					}
				}
			}
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.value.indexOf("[기타]") < 0 ){
					$M.setValue("remark","");
					$M.setValue("day_board_seq","");
					$M.setValue("work_st_ti","");
					$M.setValue("s_mem_no","");
					$("#remark").prop("disabled", true);
					$("#goEtcDelBtn").hide();
				}else {
					$M.setValue("work_st_ti",event.item.day_board_time_cd);
					$M.setValue("s_mem_no",event.dataField.split("_")[0]);
				}
			});
		}

		function fnClose() {
			window.close();
		}

		function goPaper() {
			var menuName = "";
			var dt = $M.getValue("s_work_dt");

			menuName += "${inputParam.s_mem_name}님의 "
			menuName += dt.replace(/(\d{4})(\d{2})(\d{2})/g, '$1-$2-$3');
			menuName += " 업무일지에서 보낸쪽지입니다.#";
			menuName += "자료조회로 내용을 참고하세요.#"
			menuName += "#";
			var jsonObject = {
				"paper_contents" : menuName,
				"receiver_mem_no_str" : "${inputParam.s_mem_no}",	// 수신자
				"refer_mem_no_str" : "",		// 참조자
				"menu_seq" : "${page.menu_seq}",
				"pop_get_param" : "s_mem_no=${inputParam.s_mem_no}&s_work_dt=${inputParam.s_work_dt}",
				"cmd" : "N"
			}
			openSendPaperPanel(jsonObject);
		}

		// 출하캘린더 팝업
		function goOutCalPopup() {
			var param = {};
			$M.goNextPage("/sale/sale0101p13", $M.toGetParam(param), {popupStatus : ""});
		}

		// 업무리스트 팝업
		function goWorkListPop () {
			var param = {
				"s_org_code": orgCode,
				"s_search_dt": workDt
			}
			$M.goNextPage("/mmyy/mmyy0113p03", $M.toGetParam(param), {popupStatus : ""});
		}

		// 일일현황 등록 팝업
		function goNewDayBoardPop(param) {
			$M.goNextPage("/mmyy/mmyy0113p01", $M.toGetParam(param), {popupStatus : ""});
		}

		// 일일현황 상세 팝업
		function goDetailDayJobPop(memNo,docNo,div,custNo,machine_name) {
			if(div == "repair"){ // 정비일지
				var jobReportNo = docNo;
				if (jobReportNo != "") {
					var params = {
						"s_job_report_no": jobReportNo,
						"s_popup_yn" : "Y"
					};
					var popupOption = "";
					$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
				}
			}else if(div == "rental"){ // 렌탈계약
				var rentalDocNo = docNo;
				if (rentalDocNo != "") {
					var params = {
						"rental_doc_no": rentalDocNo,
						"s_popup_yn" : "Y"
					};
					var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
					$M.goNextPage('/rent/rent0101p01', $M.toGetParam(params), {popupStatus: popupOption});

				}
			}else if(div == "counsel") { //안건상담
				var machine_plant_seq = docNo;
				if (machine_plant_seq != "") {
					var params = {
						"cust_no": custNo,
						"s_machine_plant_seq": machine_plant_seq,
						// 업무일지 상세(영업부) > 영업대상고객 > 고객명 클릭 시, 해당 모델의 모든 상담내역 도출 - 김경빈
						"s_dt_yn": "N",
						"s_popup_yn" : "Y"
					};
					$M.goNextPage('/cust/cust0101p05', $M.toGetParam(params), {popupStatus: ""});
				}
			}else if(div == "etc"){ // 기타
				var etcText = docNo.replaceAll("%%","\r\n");
				if("${bean.complete_yn}" != "Y" && "${SecureUser.mem_no}" == memNo){
					$("#remark").prop("disabled", false);
					if($M.getValue("s_work_dt") == $M.getCurrentDate("yyyyMMdd")){
						$("#goEtcDelBtn").show();
					}
				}else {
					$("#remark").prop("disabled", true);
					$("#goEtcDelBtn").hide();
				}
				$M.setValue("day_board_seq",machine_name);
				$M.setValue("remark",etcText);
				$M.setValue("s_mem_no",memNo);
			}else{ // 렌탈출고/회수
				var rentalDocNo = docNo;
				if (rentalDocNo != "") {
					var params = {
						"rental_doc_no": rentalDocNo,
						"s_popup_yn" : "Y"
					};
					var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
					$M.goNextPage('/rent/rent0102p01', $M.toGetParam(params), {popupStatus : popupOption});

				}
			}

		}

		// 화면 새로고침
		function fnReload(){
			location.reload();
		}

		// 예약 마감 상태
		function fnShowResvState() {
			var amResv = $M.getValue("am_resv_able_yn");
			var pmResv = $M.getValue("pm_resv_able_yn");

			var state = "오전 : " + (amResv == "Y" ? "예약가능" : "예약마감")
			            + ", 오후 : " + (pmResv == "Y" ? "예약가능" : "예약마감");

			$("#resv_state").html(state);
		}


		function createAUIGridBottom() {
			var gridPros = {
				showRowNumColumn : true
			}

			var columnLayout = [
				{
					headerText  : "사원명",
					dataField : "mem_name"
				},
				{
					headerText : "구분",
					dataField : "holiday_type_name",
					width : "15%"
				},
				{
					headerText : "일정기간",
					dataField : "schedule_term",
					width : "30%"
				},
				{
					headerText : "내용",
					dataField : "content",
					width : "30%"
				}
			];


			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridBottom, ${tomorrowList});
		}

		function goComplete() {

			if(repairReCnt > 0){
				alert("정비예약건을 처리하셔야 일지가 완료되니 확인하시기 바랍니다.");
				return;
			}
			var param = {
				"work_diary_seq" : "${bean.work_diary_seq}",
				"work_dt": workDt,
				"work_text": $M.getCurrentDate("yyyy년 MM월 dd일") + " 일지 완료"
			}
			$M.goNextPageAjaxMsg("일지작성을 마감하시겠습니까?","/work/savecomplete", $M.toGetParam(param) , {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
			);
		}

		function fnCancel() {

			if("${bean.work_diary_seq}" == ""){alert("일지작성 전입니다."); return false;}
			var param = {
				"work_diary_seq" : "${bean.work_diary_seq}",
				"s_mem_no" : "${inputParam.s_mem_no}"
			};
			$M.goNextPageAjaxMsg("일지작성완료 취소하시겠습니까?","/work/cancel", $M.toGetParam(param) , {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
			);
		}
	</script>
</head>
<body>
<div class="layout-box">
	<input type="hidden" name="am_resv_able_yn" value="${info.am_resv_able_yn}">
	<input type="hidden" name="pm_resv_able_yn" value="${info.pm_resv_able_yn}">
	<input type="hidden" name="s_org_code" value="${inputParam.s_org_code}">
	<input type="hidden" id="work_st_ti" name="work_st_ti" value=""/>
	<input type="hidden" id="s_mem_no" name="s_mem_no" value=""/>
	<input type="hidden" id="day_board_seq" name="day_board_seq" value="${bean.day_board_seq}"/>
	<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<div class="contents">
				<!-- 기본 -->
					<div class="search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="65px">
								<col width="120px">
								<col width="55px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회일자</th>
								<td>
									<div class="form-row inline-pd" style="padding-left: 10px;">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_work_dt" name="s_work_dt" dateFormat="yyyy-MM-dd"  value="${s_work_dt}" alt="조회일자">
										</div>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
								</td>
								<td>
									${inputParam.s_dayofweek} ${inputParam.s_schedule != '' ? '[' : '' }<span class="text-primary">${inputParam.s_schedule}</span>${inputParam.s_schedule != '' ? ']' : '' }
									<c:if test="${inputParam.mng_yn ne 'Y'}"><button type="button" class="btn btn-default" onclick="javascript:goPaper()">쪽지</button></c:if>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<div class="btn-group">
							<div class="left">
								<!-- 탭 -->
								<ul class="tabs-c mt5" onclick="javascript:event.stopImmediatePropagation();" style="width: 265px;">
									<li class="tabs-item">
										<fmt:parseDate value="${inputParam.s_yesterday}" var="yesterday_dt" pattern="yyyyMMdd"/>
										<a href="#" id="beforeDay" onclick="fnSelectDay('${inputParam.s_yesterday}')" class="tabs-link font-12" ><fmt:formatDate value="${yesterday_dt}" pattern="yyyy-MM-dd" /></a>
									</li>
									<li class="tabs-item">
										<fmt:parseDate value="${inputParam.s_work_dt}" var="today_dt" pattern="yyyyMMdd"/>
										<a href="#" id="toDay" class="tabs-link font-12 active"><fmt:formatDate value="${today_dt}" pattern="yyyy-MM-dd" /></a>
									</li>
									<li class="tabs-item">
										<fmt:parseDate value="${inputParam.s_tomorrow}" var="tomorrow_dt" pattern="yyyyMMdd"/>
										<a href="#" id="afterDay" onclick="fnSelectDay('${inputParam.s_tomorrow}')" class="tabs-link font-12"><fmt:formatDate value="${tomorrow_dt}" pattern="yyyy-MM-dd" /></a>
									</li>
								</ul>
								<!-- /탭 -->
							</div>
							<div class="right">
								<span id="resv_state">
								</span>
								<c:if test="${inputParam.mng_yn ne 'Y'}">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</c:if>
							</div>
						</div>
					</div>


				<!-- /그리드 타이틀, 컨트롤 영역 -->
				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
				<div class="row">
					<div class="col-7">
						<!-- 업무내용 상세 -->
						<div class="btn-group mt10">
							<h4>업무내용 상세</h4>
							<div class="right">
								<c:if test="${inputParam.mng_yn ne 'Y'}">
								<button type="button" class="btn btn-light" id="goEtcSaveBtn" onclick="javascript:goEtcSave()">기타저장</button>
								<button type="button" class="btn btn-light" style="display: none;" id="goEtcDelBtn" onclick="javascript:goEtcDel()">기타삭제</button>
								</c:if>
							</div>
						</div>
						<textarea class="form-control mt5" style="height: 250px;" id="remark" name="remark" disabled alt="업무내용 상세" ></textarea>
						<!-- /업무내용 상세 -->

					</div>
					<div class="col-5">
						<!-- 내일 인사일정 -->
						<div class="title-wrap mt10">
							<h4>내일 인사일정</h4>
						</div>
						<div id="auiGridBottom" style="margin-top: 5px; height: 250px;"></div>
						<!-- /내일 인사일정 -->
					</div>
				</div>
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
		</div>

		<c:if test="${inputParam.s_popup_yn ne 'Y'}">
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</c:if>
	</div>
	<!-- /contents 전체 영역 -->
</div>
</body>
</html>