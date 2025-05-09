<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 출하서비스일지 등록
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-22 11:12:10
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridOut;
		var auiGridPart;
		var auiGridAsTodos;
		var maxByte = 4000;

		var i = 1;
		var sessionCehckTime = 1000 * 60 * 5;
		$(document).ready(function() {
			// 출하점검내역
			createAUIGridOut();
			// 부품내역
			createAUIGridPart();
			// 서비스미결
			createAUIGridAsTodo();

			fnInit();
		});

		function fnInit() {
			setInterval(function () {
				fnSessionCheck();
			}, sessionCehckTime);
		}

		function fnSessionCheck() {
			$M.goNextPageAjax('/session/check', '', {method: 'GET', loader: false},
					function (result) {
						console.log($M.getCurrentDate("yyyyMMddHHmmss"));
					}
			);
		}

		function fnPrint() {
			alert("저장 후 출력 가능합니다.");
		}

		// 차대번호, 차주명 조회
		function fnSetInformation(data) {
			var param = {
				"s_machine_seq" : data.machine_seq
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
					function (result) {
						if(result.success) {
							dataSetting(result);
						}
					}
			);
		}

		// 장비, 고객 정보 Setting
		function dataSetting(result) {
			// 장비관련
			$M.setValue(result.machineBean);
			$M.setValue("__s_machine_seq", result.machineBean.machine_seq);
			$M.setValue("machine_plant_seq", result.machineBean.machine_plant_seq);
			$M.setValue("maker_cd", result.machineBean.maker_cd);


			$("#cap").html(result.machineBean.cap);
			if(result.machineBean.cap == "미적용") {
				$("#plan_dt").prop("disabled", true);
			}

			// 고객정보
			$M.setValue(result.custBean);
			$M.setValue("__s_cust_no", result.custBean.cust_no);
			$M.setValue("op_hour", result.machineBean.op_hour);

			// 서비스미결
			AUIGrid.setGridData(auiGridAsTodos, result.asTodoList);
		}

		// 문자발송
		function fnSendSms(type) {
			var name;
			var hpNo;

			if(type == "cust") {
				name = $M.getValue("cust_name");
				hpNo = $M.getValue("hp_no");
			} else if(type == "sale") {
				name = $M.getValue("sale_mem_name");
				hpNo = $M.getValue("sale_mem_hp_no");
			} else if(type == "serv") {
				name = $M.getValue("service_mem_name");
				hpNo = $M.getValue("service_mem_hp_no");
			}

			var param = {
				"name" : name,
				"hp_no" : hpNo
			};
			openSendSmsPanel($M.toGetParam(param));
		}

		// CAP이력 팝업
		function goCapLog() {
			var machineSeq = $M.getValue("machine_seq");
			if(machineSeq == "") {
				alert("차대번호를 먼저 조회해주세요.");
				return;
			}

			var params = {
				"s_machine_seq" : machineSeq
			};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
			$M.goNextPage('/serv/serv0101p14', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 네이버 지도 호출
		function goMap() {
			var params = {};
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
			$M.goNextPage('https://map.naver.com', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 정비시간 계산
		function fnCalcRepairHour() {

			// 정비시작 - 시(분으로 환산)
			var repairStHour = $M.toNum($M.getValue("repair_st_ti_h")) * 60;
			// 정비시작 - 분
			var repairStMin = $M.toNum($M.getValue("repair_st_ti_m"));
			// 정비시작 분으로 환산
			var repairStart = repairStHour + repairStMin;

			// 정비종료 - 시(분으로 환산)
			var repairEdHour = $M.toNum($M.getValue("repair_ed_ti_h")) * 60;
			// 정비종료 - 분
			var repairEdMin = $M.toNum($M.getValue("repair_ed_ti_m"));
			// 정비종료 분으로 환산
			var repairEnd = repairEdHour + repairEdMin;

			// 최종시간 계산 - 시로 환산
			var finalTime = (repairEnd - repairStart) / 60;
			finalTime = finalTime.toFixed(1);

			// 정비시간 Setting
			if(finalTime > 0) {
				$M.setValue("repair_hour", finalTime);
				$M.setValue("total_repair_hour", finalTime);
			}
		}

		function fnCalcStandardHour() {
			$M.setValue("total_standard_hour", $M.getValue("standard_hour"));
		}

		// 공임배분 -> 상세페이지에서만 호출 가능.
		function goRepairCowoker() {
			if (confirm("공임배분은 무상일 경우에만 해야합니다.\n무상정비가 맞습니까?") == false) {
				return false;
			}
			var param = {
				"parent_js_name" : "fnSetRepairCowoker",
				"work_total_amt" : $M.setComma($M.toNum($M.getValue("work_total_amt")))
			};
			

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=450, left=0, top=0";
			$M.goNextPage('/serv/serv0102p03', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 공임배분 Data Setting
		function fnSetRepairCowoker(data) {
			var co_mem_no = [];
			var co_work_rate = [];
			var co_work_amt = [];

			for(var i in data) {
				co_mem_no.push(data[i].mem_no);
				co_work_rate.push(data[i].work_rate);
				co_work_amt.push(data[i].work_amt);
			}

			var option = {
				isEmpty : true
			};

			$M.setValue("co_mem_no_str", $M.getArrStr(co_mem_no, option));
			$M.setValue("co_work_rate_str", $M.getArrStr(co_work_rate, option));
			$M.setValue("co_work_amt_str", $M.getArrStr(co_work_amt, option));

			var cowoker = data[0].mem_name;
			var cowokerCnt = data.length - 1;
			if(data.length > 1) {
				cowoker += " 외" + cowokerCnt + "명";
			}

			$M.setValue("cowoker", cowoker);
		}

		// 4.출하점검내역 - 자주쓰는출하내역
		function goBookmark() {
			var machineSeq = $M.getValue("machine_seq");
			if(machineSeq == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			var params = {
				"parent_js_name" : "fnSetAsRepairOutCheck",
				"maker_cd" : $M.getValue("maker_cd"),
				"machine_name" : $M.getValue("machine_name"),
				"machine_plant_seq" : $M.getValue("machine_plant_seq")
			};

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=650, left=0, top=0";
			$M.goNextPage('/serv/serv0102p14', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 4.출하점검내역 - 자주쓰는출하내역
		function fnSetAsRepairOutCheck(data) {
			var item = new Object();
			for(var j in data) {
				item.out_text = data[j].item.out_text;
				item.seq_no = "";
				item.row_num = i;

				AUIGrid.addRow(auiGridOut, item, 'last');
			}
			i++;
		}

		// 4.출하점검내역 - 행추가
		function fnAdd() {
			if(fnCheckGridEmpty()) {
				var item = new Object();
				item.out_text = "";
				item.seq_no = "";
				item.row_num = i;
				AUIGrid.addRow(auiGridOut, item, 'last');
			};

			i++;
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGridOut, ["out_text"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 결재요청
		function goRequestApproval() {
			goSave('requestAppr');
		}

		// 저장
		function goSave(isRequestAppr) {
			var frm = document.main_form;
			// validationcheck
			if($M.validation(frm,
					{field:["body_no", "cust_name", "repair_st_ti_h",
							"repair_st_ti_m", "repair_ed_ti_h", "repair_ed_ti_m"]})==false) {
				return;
			};

			if($M.getValue("job_type_cd") == "") {
				alert("정비구분을 선택해주세요.");
				return;
			}

			var startTiH = $M.toNum($M.getValue("repair_st_ti_h"));
			var startTiM = $M.toNum($M.getValue("repair_st_ti_m"));
			var endTiH = $M.toNum($M.getValue("repair_ed_ti_h"));
			var endTiM = $M.toNum($M.getValue("repair_ed_ti_m"));

			if(startTiH < 1 || startTiH > 23) {
				alert("정비시작 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
				return;
			}

			if(startTiM > 59) {
				alert("정비시작 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
				return;
			}

			if(endTiH < 1 || endTiH > 23) {
				alert("정비종료 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
				return;
			}

			if(endTiM > 59) {
				alert("정비종료 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
				return;
			}

			if((startTiH > endTiH) || (startTiH == endTiH && startTiM > endTiM)) {
				alert("정비시작시간은 정비종료시간보다 늦을 수 없습니다.");
				return;
			}

			// 3.정비정보 Setting
			var travelStTi = $M.getValue("travel_st_ti_h") + $M.getValue("travel_st_ti_m");
			var travelEdTi = $M.getValue("travel_ed_ti_h") + $M.getValue("travel_ed_ti_m");
			var repairStTi = $M.getValue("repair_st_ti_h") + $M.getValue("repair_st_ti_m");
			var repairEdTi = $M.getValue("repair_ed_ti_h") + $M.getValue("repair_ed_ti_m");

			$M.setValue(frm, "travel_st_ti", travelStTi);
			$M.setValue(frm, "travel_ed_ti", travelEdTi);
			$M.setValue(frm, "repair_st_ti", repairStTi);
			$M.setValue(frm, "repair_ed_ti", repairEdTi);

			var gridData = fnChangeGridDataToForm(auiGridOut);
			$M.copyForm(gridData, frm);

			var msg = "";
			if(isRequestAppr != undefined) {
				// 결재요청 Setting
				$M.setValue("save_mode", "appr");
				msg = "결재요청 하시겠습니까?";
			} else {
				$M.setValue("save_mode", "save");
				msg = "저장 하시겠습니까?";
			}

			$M.goNextPageAjaxMsg(msg, this_page + "/save", gridData, {method : "POST"},
				function(result) {
					if(result.success) {
						$M.setValue("as_no", result.as_no);
						// if(isRequestAppr != undefined) {
						// 	fnClose();
						//
						// 	goAsdetail();
						// } else {
							alert("처리가 완료되었습니다.");
							fnClose();

							goAsdetail();
						// }
					}
				}
			);
		}

		function goAsdetail() {
			var params = {
				"s_as_no" : $M.getValue("as_no")
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
			$M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 결재
		function goApproval() {
			var params = {
				"s_as_no" : $M.getValue("as_no"),
			};

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
			$M.goNextPage('/serv/serv0102p02', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 출하점검내역
		function createAUIGridOut() {
			var gridPros = {
				showStateColumn : true,
				showRowNumColumn : true,
				editable : true
			};

			var columnLayout = [
				{
					headerText : "출하내역",
					dataField : "out_text",
					style : "aui-left aui-editable",
					width : "80%"
				},
				{
					headerText : "행번호",
					dataField : "row_num",
					visible : false
				},
				{
					headerText : "순번",
					dataField : "seq_no",
					visible : false
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridOut, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGridOut);
							} else {
								AUIGrid.restoreSoftRows(auiGridOut, "selectedIndex");
								AUIGrid.update(auiGridOut);
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridOut = AUIGrid.create("#auiGridOut", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridOut, []);
		}

		// 부품내역
		function createAUIGridPart() {
			var gridPros = {
				showStateColumn : false,
				showRowNumColumn : true,
				editable : false
			};

			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "20%"
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					width : "20%"
				},
				{
					headerText : "수량",
					dataField : "qty",
					width : "10%"
				},
				{
					headerText : "단가",
					dataField : "unit_price",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "금액",
					dataField : "amount",
					dataType : "numeric",
					formatString : "#,##0"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridPart = AUIGrid.create("#auiGridPart", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridPart, []);
		}

		// 서비스미결
		function createAUIGridAsTodo() {
			var gridPros = {
				showStateColumn : false,
				showRowNumColumn : true,
				editable : false
			};

			var columnLayout = [
				{
					headerText : "예정일자",
					dataField : "plan_dt",
					style : "aui-center",
					width : "20%",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "미결사항",
					dataField : "todo_text",
					style : "aui-left",
					width : "40%",
				},
				{
					headerText : "처리사항",
					dataField : "proc_text",
					style : "aui-left",
					width : "40%",
				},
				{
					headerText : "AS미결번호",
					dataField : "as_todo_seq",
					visible : false
				},
				{
					headerText : "장비대장번호",
					dataField : "machine_seq",
					visible : false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridAsTodos = AUIGrid.create("#auiGridAsTodos", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridAsTodos, []);
		}

		function show(id) {
			document.getElementById(id).style.display="block";
		}
		function hide(id) {
			document.getElementById(id).style.display="none";
		}

		function fnSetMissMem(data) {
			$M.setValue("miss_mem_name", data.mem_name);
			$M.setValue("miss_mem_no", data.mem_no);
		}

		// 글자수 체크
		function fnChkByte(obj) {
			var str = obj.value;
			var str_len = str.length;
			var rbyte = 0;
			var rlen = 0;
			var pass_len = 0;
			var one_char = "";
			for (var i = 0; i < str_len; i++) {
				one_char = str.charAt(i);
				if (escape(one_char).length > 4) {
					rbyte += 2; //한글2Byte
				} else {
					rbyte++; //영문 등 나머지 1Byte
				};
				if (rbyte <= maxByte) {
					rlen = i + 1; //return할 문자열 갯수
					pass_len = rbyte;
				};
			}

			if(rbyte > maxByte) {
				alert("최대 글자수를 초과하였습니다.");
				$M.setValue("repair_text", $M.getValue("repair_text").substring(0, rlen));
				rbyte = pass_len;
			}
			$('#repair_text_cnt').html('글자수 : ' + rbyte + ' / ' + maxByte);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="as_repair_type_ro" name="as_repair_type_ro" value="O">
<input type="hidden" id="as_type" name="as_type" value="REPAIR">
<input type="hidden" id="save_mode" name="save_mode">
<input type="hidden" id="__s_machine_seq" name="__s_machine_seq">
<input type="hidden" id="machine_seq" name="machine_seq">
<input type="hidden" id="__s_cust_no" name="__s_cust_no">
<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" name="service_mem_hp_no" id="service_mem_hp_no">
<input type="hidden" name="sale_mem_hp_no" id="sale_mem_hp_no">
<input type="hidden" name="machine_plant_seq" id="machine_plant_seq">
<input type="hidden" name="maker_cd" id="maker_cd">
<input type="hidden" id="__s_reg_type" name="__s_reg_type" value="I">
<input type="hidden" id="__s_menu_type" name="__s_menu_type" value="S">
<input type="hidden" id="as_no" name="as_no">
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<div class="left approval-left">
					<div></div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<!-- 결재영역 -->
				<div class="p10" style="margin-left: 10px;">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
				<!-- /결재영역 -->
			</div>
			<div>
			<!-- 상단 폼테이블 -->
				<div class="row mt10">
					<!-- 1. 장비정보 -->
					<div class="col-6">
					<table class="table-border mt5">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right essential-item">차대번호</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-7">
										<div class="input-group">
											<input type="text" id="body_no" name="body_no" class="form-control border-right-0 essential-bg" readonly="readonly" required="required" alt="차대번호">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchDeviceHisPanel('fnSetInformation');" ><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div class="col-4">
										<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
											<jsp:param name="li_machine_type" value="__machine_detail#__repair_history#__machine_ledger#__as_todo#__campaign#__work_db"/>
										</jsp:include>
									</div>
								</div>
							</td>
							<th class="text-right">장비모델</th>
							<td>
								<input type="text" id="machine_name" name="machine_name" class="form-control" readonly="readonly">
							</td>
							<th class="text-right">출하일자</th>
							<td>
								<input type="text" id="out_dt" name="out_dt" class="form-control width120px" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">CAP<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show('help_operation')" onmouseout="javascript:hide('help_operation')"></i></th>
							<div class="con-info" id="help_operation" style="max-height: 500px; top: 90%; left: 7%; width: 230px; display: none;">
								<ul class="">
									<ol style="color: #666;">&nbsp;※ CAP적용/미적용은 장비대장에서 처리</ol>
								</ul>
							</div>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<span id="cap"></span>
									</div>
									<div class="col width100px">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goCapLog();">CAP이력</button>
									</div>
								</div>
							</td>
							<th class="text-right">CAP회차</th>
							<td>
								-
							</td>
							<th class="text-right">CAP예정일자</th>
							<td>
								-
							</td>
						</tr>
						</tbody>
					</table>
					</div>
					<!-- /1. 장비정보 -->
					<!-- 2. 고객정보 -->
					<div class="col-6">
					<table class="table-border mt5">
						<colgroup>
							<col width="70px">
							<col width="190px">
							<col width="70px">
							<col width="190">
							<col width="90px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right essential-item">차주명</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-7">
										<div class="input-group">
											<input type="text" id="cust_name" name="cust_name" class="form-control essential-bg" readonly="readonly" required="required" alt="차주명">
										</div>
									</div>
									<div class="col-4">
										<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
											<jsp:param name="cust_no" value=""/>
											<jsp:param name="jobType" value="C"/>
											<jsp:param name="li_type" value="__cust_dtl#__ledger#__visit_history#__as_call_dtl"/>
										</jsp:include>
									</div>
								</div>
							</td>
							<th class="text-right">휴대폰</th>
							<td>
								<div class="input-group width140px">
									<input type="text" id="hp_no" name="hp_no" class="form-control border-right-0" format="phone" readonly="readonly">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms('cust');" ><i class="material-iconsforum"></i></button>
								</div>
							</td>
							<th class="text-right">업체명</th>
							<td>
								<input type="text" id="breg_name" name="breg_name" class="form-control" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">주소</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-6">
										<input type="text" id="addr1" name="addr1" class="form-control" readonly="readonly">
									</div>
									<div class="col-6">
										<input type="text" id="addr2" name="addr2" class="form-control" readonly="readonly">
									</div>
								</div>
							</td>
							<th class="text-right">쿠폰잔액/미수</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" id="misu_amt" name="misu_amt" class="form-control text-right" readonly="readonly" format="decimal">
									</div>
									/&nbsp;
									<div class="col width100px">
										<input type="text" id="di_balance_amt" name="di_balance_amt" class="form-control text-right" readonly="readonly" format="decimal">
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					</div>
				</div>
				<!-- /2. 고객정보 -->
				<!-- 3. 정비정보 -->
				<div class="title-wrap mt10">
					<div class="left">
						<h4>정비정보</h4>
					</div>
					<div class="right">
						<button type="button" class="btn btn-default" onclick="javascript:goMap();"><i class="material-iconsplace text-default"></i>지도보기</button>
					</div>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="85px">
						<col width="">
						<col width="85px">
						<col width="">
						<col width="85px">
						<col width="">
						<col width="110px">
						<col width="">
						<col width="85px">
						<col width="">
						<col width="85px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right essential-item">정비구분</th>
						<td>
							<select class="form-control" name="job_type_cd" id="job_type_cd" required="required" alt="정비구분" disabled="disabled">
								<option value="5" selected="selected">출하</option>
								<c:forEach var="list" items="${codeMap['JOB_TYPE']}">
									<option value="${list.code_value}" ${list.code_value == result.job_type_cd ? 'selected="selected"' : ''} >${list.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">유무상구분</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="cost_yn_y" name="cost_yn" value="Y" required="required" alt="유무상구분" disabled>
								<label class="form-check-label" for="cost_yn_y">유상</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="cost_yn_n"  name="cost_yn" value="N" checked="checked" required="required" alt="유무상구분">
								<label class="form-check-label" for="cost_yn_n">무상</label>
							</div>
						</td>
						<th class="text-right essential-item">정비종류</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="job_case_ti" name="job_case_ti" checked="checked" value="I" required="required" alt="정비종류">
								<label class="form-check-label">입고</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="job_case_ti" name="job_case_ti" value="T" disabled="disabled" required="required" alt="정비종류">
								<label class="form-check-label">출장</label>
							</div>
						</td>
						<th class="text-right">재정비</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="rework_ync_n" name="rework_ync" value="N" checked="checked" required="required" alt="재정비">
								<label class="form-check-label" for="rework_ync_n">N</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="rework_ync_y"  name="rework_ync" value="Y" required="required" alt="재정비">
								<label class="form-check-label" for="rework_ync_y">Y</label>
							</div>
						</td>
						<th class="text-right">정비과실자</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<div class="input-group width100px">
										<input type="text" id="miss_mem_name" name="miss_mem_name" class="form-control border-right-0" readonly="readonly" alt="정비과실자">
										<input type="hidden" id="miss_mem_no" name="miss_mem_no">
										<button type="button" id="miss_mem_no_btn" name="miss_mem_btn" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('fnSetMissMem', 's_org_code=5000&s_repair_yn=Y');"><i class="material-iconssearch"></i></button>
									</div>
								</div>
							</div>
						</td>
						<th class="text-right">가동시간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width70px">
									<input type="text" id="op_hour" name="op_hour" class="form-control">
								</div>
								<div class="col width33px">
									hr
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">정비시간합계</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width70px">
									<input type="text" class="form-control text-right" id="total_repair_hour" name="total_repair_hour" datatype="int" readonly="readonly">
								</div>
								<div class="col width33px">
									hr
								</div>
							</div>
						</td>
						<th class="text-right">규정시간합계</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width70px">
									<input type="text" class="form-control text-right" id="total_standard_hour" name="total_standard_hour" readonly="readonly">
								</div>
								<div class="col width33px">hr</div>
							</div>
						</td>
						<th class="text-right">동행정비</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-5">
									<input type="text" class="form-control" id="cowoker" name="cowoker" readonly="readonly">
								</div>
								<div>
									<button type="button" class="btn btn-primary-gra " onclick="javascript:goRepairCowoker();">공임배분</button>
								</div>
							</div>
						</td>
						<th class="text-right">공임비용</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="work_total_amt" name="work_total_amt" datatype="int" format="decimal" readonly="readonly" value="0">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">부품비용</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="part_total_amt" name="part_total_amt" datatype="int" format="decimal" readonly="readonly" value="0">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">출장위치</th>
						<td>
							<input type="text" class="form-control width200px" id="area_name" name="area_name" readonly="readonly">
						</td>
						<th class="text-right">출장출발</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width40px">
									<input type="text" id="travel_st_ti_h" name="travel_st_ti_h" class="form-control text-right" minlength="2" maxlength="2" readonly="readonly">
								</div>
								<div class="col width16px">시</div>
								<div class="col width35px">
									<input type="text" id="travel_st_ti_m" name="travel_st_ti_m" class="form-control text-right" minlength="2" maxlength="2" readonly="readonly">
								</div>
								<div class="col width16px">분</div>
							</div>
						</td>
						<th class="text-right">출장도착</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width40px">
									<input type="text" id="travel_ed_ti_h" name="travel_ed_ti_h" class="form-control text-right" minlength="2" maxlength="2" readonly="readonly">
								</div>
								<div class="col width16px">시</div>
								<div class="col width35px">
									<input type="text" id="travel_ed_ti_m" name="travel_ed_ti_m" class="form-control text-right" minlength="2" maxlength="2" readonly="readonly">
								</div>
								<div class="col width16px">분</div>
							</div>
						</td>
						<th class="text-right">이동시간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width70px">
									<input type="text" class="form-control text-right" id="move_hour" name="move_hour" readonly="readonly">
								</div>
								<div class="col width33px">
									hr
								</div>
							</div>
						</td>
						<th class="text-right">출장비용</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="travel_final_expense" name="travel_final_expense" readonly="readonly" value="0">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">총액(VAT별도)</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="total_amt" name="total_amt" datatype="int" format="decimal" readonly="readonly" value="0">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<input type="hidden" class="form-control text-right" id="travel_discount_amt" name="travel_discount_amt" datatype="int" format="decimal" readonly="readonly" value="0">
					</tr>
					</tbody>
				</table>
				<!-- 3. 정비정보 -->
			</div>
			<!-- /상단 폼테이블 -->

			<!-- 중간 폼테이블 -->
			<div class="row mt10">
				<!-- 중간좌측 폼테이블 -->
				<div class="col-4">
					<!-- 4. 정비분류 -->
					<div class="title-wrap">
						<div class="left">
							<h4>출하점검내역</h4>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
						</div>
					</div>
					<div id="auiGridOut" style="margin-top: 5px; height: 200px;"></div>
					<!-- /4. 정비분류 -->
					<!-- 부품내역 -->
					<div class="title-wrap mt5">
						<h4>부품내역</h4>
						<%--<button type="button" class="btn btn-outline-success">상세보기</button>--%>
					</div>
					<div id="auiGridPart" style="margin-top: 5px; height: 120px;"></div>
					<div class="title-wrap mt5">
						<h4>서비스미결</h4>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
					</div>
					<div id="auiGridAsTodos" style="margin-top: 5px; height: 110px;"></div>
					<div class="title-wrap mt5">
						<h4>참고사항</h4>
						<%--<button type="button" class="btn btn-outline-success">상세보기</button>--%>
					</div>
					<div>
						<textarea class="form-control" id="ref_text" name="ref_text" style="height: 70px;" placeholder="참고사항 관련 메모가 들어갑니다."></textarea>
					</div>
					<!-- /부품내역 -->
				</div>
				<!-- /중간좌측 폼테이블 -->

				<!-- 중간센터 폼테이블 -->
				<div class="col-8">
					<!-- 5. 정비내역 -->
					<ul class="tabs-c">
						<li class="tabs-item">
<%--							<a href="#" class="tabs-link font-12 active" dateFormat="yyyy-MM-dd">${inputParam.s_current_dt}</a>--%>
							<input type="text" dateFormat="yyyy-MM-dd" class="tabs-link font-12 active" id="as_dt" name="as_dt" value="${inputParam.s_current_dt}" disabled>
						</li>
					</ul>
					<input type="hidden" id="day_seq_no" name="day_seq_no" value="0" alt="정비순서">
					<table class="table-border mt10">
						<colgroup>
							<col width="85px">
							<col width="">
							<col width="85px">
							<col width="">
							<col width="85px">
							<col width="">
							<col width="85px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right essential-item">정비시작</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width40px">
										<input type="text" id="repair_st_ti_h" name="repair_st_ti_h" class="form-control text-right essential-bg" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour();" required="required" alt="정비시작(시)">
									</div>
									<div class="col width16px">시</div>
									<div class="col width35px">
										<input type="text" id="repair_st_ti_m" name="repair_st_ti_m" class="form-control text-right essential-bg" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour();" required="required" alt="정비시작(분)">
									</div>
									<div class="col width16px">분</div>
								</div>
							</td>
							<th class="text-right essential-item">정비종료</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width40px">
										<input type="text" id="repair_ed_ti_h" name="repair_ed_ti_h" class="form-control text-right essential-bg" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour();" required="required" alt="정비종료(시)">
									</div>
									<div class="col width16px">시</div>
									<div class="col width35px">
										<input type="text" id="repair_ed_ti_m" name="repair_ed_ti_m" class="form-control text-right essential-bg" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour();" required="required" alt="정비종료(분)">
									</div>
									<div class="col width16px">분</div>
								</div>
							</td>
							<th class="text-right">정비시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<input type="text" class="form-control text-right" id="repair_hour" name="repair_hour" datatype="int" readonly="readonly">
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
							<th class="text-right">규정시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<input type="text" class="form-control text-right" id="standard_hour" name="standard_hour" onchange="javascript:fnCalcStandardHour();">
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<div class="title-wrap mt10">
						<div class="left">
							<h4>정비내역</h4>
							<span class="ml5" id="repair_text_cnt" style="font-weight: bold; color : red;">
								글자수 : 0 / 4000
							</span>
						</div>
					</div>
					<div class="mt5" style="height: 365px;">
						<textarea class="form-control" style="height: 100%;" id="repair_text" name="repair_text" placeholder="정비내역을 입력 할 수 있습니다." onkeyUp="javascript:fnChkByte(this)"></textarea>
					</div>
					<div class="title-wrap mt5">
						<div class="left">
							<h4>결재자의견</h4>
						</div>
						<%--<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>--%>
					</div>
					<table class="table mt5">
						<colgroup>
							<col width="40px">
							<col width="">
							<col width="60px">
							<col width="">
						</colgroup>
						<thead>
						<tr>
							<td colspan="5">
								<div class="fixed-table-container" style="width: 100%; height: 110px;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
									<div class="fixed-table-wrapper">
										<table class="table-border doc-table md-table">
											<colgroup>
												<col width="40px">
												<col width="140px">
												<col width="55px">
												<col width="">
											</colgroup>
											<thead>
											<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
											<tr><th class="th" style="font-size: 12px !important">구분</th>
												<th class="th" style="font-size: 12px !important">결재일시</th>
												<th class="th" style="font-size: 12px !important">담당자</th>
												<th class="th" style="font-size: 12px !important">특이사항</th>
											</tr></thead>
											<tbody>
											<c:forEach var="list" items="${apprMemoList}">
												<tr>
													<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
													<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
													<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
													<td class="td" style="font-size: 12px !important">${list.memo }</td>
												</tr>
											</c:forEach>
											</tbody>
										</table>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
</html>