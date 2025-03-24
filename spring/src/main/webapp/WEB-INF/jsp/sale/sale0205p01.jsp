<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비대장관리 > null > 장비대장상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-05-18 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<script type="text/javascript" src="/static/js/qrcode.min.js"></script>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGridMid;
		var auiGridCap;
		var auiGridSARError;
		var auiGridSARLoc;
		var optListMap = ${optListMap};

		var submitType = ""; // 첨부서류
		var codeMapDocFileArray = JSON.parse('${codeMapJsonObj['MCH_SALE_DOC_FILE']}');

		$(document).ready(function () {
			fnInit();
			// 부품내역
			createMiddleAUIGrid();
			// CAP이력
			createCapAUIGrid();
			// Q&A 12224 따음표 쓰면 에러라 백틱으로 변경 210811 김상덕
			if(`${machineSarMap}` != ""){
				// SAR 에러코드
				createSARErrorAUIGrid();
				// SAR 위치정보
				createSARLocAUIGrid();
			}

			// qr코드 그리기
			if (${not empty list.qr_no}) {
				new QRCode(document.getElementById("qr_image"), {
					text: "${list.qr_no}",
					width: 30,
					height: 30,
				});
				$("#qr_image > img").css({"margin":"auto"});
			} else {
				$("#qr_image").html("미등록");
			}
		});

		function fnInit() {
			if ("${SecureUser.org_type}" != "BASE") {
// 				$("#in_org_code").prop("disabled", true);
				$("#in_org_name").prop("disabled", true);
			}

			var optCodeList = ${optCodeList};
			$("#opt_list option").remove();
			$("#opt_list").append(new Option('옵션품목', ""));

			for (var i = 0; i < optCodeList.length; i++) {
				if (optListMap.hasOwnProperty(optCodeList[i])) {
					var optList = optListMap[optCodeList[i]];
					$("#opt_list").append(new Option(optList[0].opt_kor_name, optList[0].opt_code));
				}
			}

			$("#opt_list").change(function () {
				optListChange();
			});

			$M.setValue("__s_body_no", $M.getValue("body_no"));
			$M.setValue("origin_body_no", $M.getValue("body_no"));
		}

		function optListChange() {

			var param = {
				"s_machine_seq": $M.getValue("machine_seq"),
				"s_opt_code": $M.getValue("opt_list")
			};

			$M.goNextPageAjax(this_page + '/searchOpt', $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGridMid, result.list);
						} else {
							AUIGrid.clearGridData(auiGridMid);
							return false;
						}
					}
			);
		}

		function show() {
			document.getElementById("machine_operation").style.display = "block";
		}

		function hide() {
			document.getElementById("machine_operation").style.display = "none";
		}

		// 장비차주변경 정보
		function fnSetMachineCust(data) {
			// alert(JSON.stringify(data));
			$M.setValue("cust_name", data.cust_name);
			$M.setValue("cust_no", data.cust_no);
			$M.setValue("real_hp_no", data.hp_no);
			$M.setValue("hp_no", data.hp_no);
			$M.setValue("breg_name", data.breg_name);

			$M.setValue("__s_cust_no", data.cust_no);
			$M.setValue("__s_cust_name", data.cust_name);
			$M.setValue("__s_hp_no", data.hp_no);
		}

		// 기본 조직도 조회
		function setOrgMapPanel(result) {
			// alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		// 고객조회 결과 test
		function setCustInfo(row) {
			$M.setValue("cust_name", row.real_cust_name);
			$M.setValue("cust_no", row.cust_no);
			$M.setValue("real_hp_no", row.real_hp_no);
			$M.setValue("breg_name", row.breg_name);

			// 장비차주 셋팅
			$M.setValue("machine_cust_no", row.cust_no);
			$M.setValue("machine_change_dt", $M.getCurrentDate());
		}

		function setSendSMSInfo(row) {
			// alert(JSON.stringify(row));
		}

		function fnSetMemberInfo(data) {
			// alert(JSON.stringify(data));
		}

		function fnSetJobOrder(data) {
			// alert(JSON.stringify(data));
		}

		// 문자발송
		function fnSendSms(type) {
			var name;
			var hpNo;

			if (type == "cust") {
				name = $M.getValue("cust_name");
				hpNo = $M.getValue("hp_no");
			} else if (type == "driver") {
				name = $M.getValue("driver_name");
				hpNo = $M.getValue("driver_hp_no");
			}

			var param = {
				"name": name,
				"hp_no": hpNo
			};
			openSendSmsPanel($M.toGetParam(param));
		}

		function goReCallList() {
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=500, left=0, top=0";
			$M.goNextPage('/serv/serv0101p06', '', {popupStatus: popupOption});
		}

		// 미결사항 팝업
		function goService() {
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=450, left=0, top=0";
			$M.goNextPage('/serv/serv0101p07', '', {popupStatus: popupOption});
		}

		// 거래시 필수확인사항 팝업
		function goCheckRequired() {
			openCheckRequiredPanel('setCheckRequired');
		}

		// 수리금액 콜백
		function fnSetReportInfo(data) {
// 			var params = {
//                     "s_job_report_no": data.job_report_no
//                 };
//             var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
//             $M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 서비스일지 호출
		function goAsType(type, asNo) {
			var params = {
				"s_as_no": asNo
			};

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=850, left=0, top=0";
			var popupOption2 = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=950, left=0, top=0";
			if (type == 'C') {
				$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
			} else if (type == 'R') {
				$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption2});
			} else {
				$M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus: popupOption2});
			}
		}

		// 무상정비목록 팝업
		function goFreeAsList() {
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=850, left=0, top=0";
			var param = {
				"machine_seq": $M.getValue("machine_seq"),
			}
			$M.goNextPage('/sale/sale0205p05', $M.toGetParam(param), {popupStatus: popupOption});
		}

		// cap적용
		function goApplyInfo() {
			var capCnt = Number($M.nvl($M.getValue("cap_cnt"), 0)) + 1;
			var capUseYn = $M.nvl($M.getValue("cap_use_yn"), "N");
			if (capUseYn == "Y") {
				alert("이미 CAP예정일이 등록되어 있어 적용이 불가능합니다.");
				return;
			}

			var msg = "CAP 예정일자를 입력하십시오.(YYYYMMDD : 연월일 8자리)";
			var releaseReason = prompt(msg);

			if(releaseReason == "" || releaseReason == null || isNaN(releaseReason) || releaseReason.length != 8) {
				alert("CAP 예정일을 정상적으로 입력해주세요.");
				return;
			}

			var param = {
				"machine_seq": $M.getValue("machine_seq"),
				"plan_dt": releaseReason,
				"use_yn": "Y",
				"cap_cnt": capCnt,
				"cap_yn": "Y"
			};

			var msg = "cap예정일을 적용하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + '/apply', $M.toGetParam(param), {method: 'POST'},
					function (result) {
						if (result.success) {
							alert("적용이 완료되었습니다.");
							location.reload();
						}
					}
			);
		}

		// cap 미적용
		function goRemoveCap() {
			var rowIndex = AUIGrid.getGridData(auiGridCap).length - 1;
			var item = AUIGrid.getItemByRowIndex(auiGridCap, rowIndex);

			var capUseYn = $M.nvl($M.getValue("cap_use_yn"), "N");
			if (capUseYn == "N") {
				alert("해지 할 예약이 없습니다.");
				return;
			}

			var msg = "CAP 해지사유를 입력하십시오.";
			var reasonText = prompt(msg);

			if(reasonText == "" || reasonText == null) {
				alert("해지 사유를 입력해주세요.");
				return;
			}

			var params = {
				"machine_seq" : item.machine_seq,
				"cap_cnt" : item.cap_cnt,
				"reason_text" : reasonText
			}

			$M.goNextPageAjaxSave(this_page + '/cap/remove', $M.toGetParam(params), {method: 'POST'},
					function (result) {
						if (result.success) {
							alert("해지가 완료되었습니다.");
							location.reload();
						}
					}
			);
		}

		function goCapLog() {
			var param = {
				"s_machine_seq": $M.getValue("machine_seq")
			}
			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=450, left=0, top=0";
			$M.goNextPage('/sale/sale0205p02', $M.toGetParam(param), {popupStatus: popupOption});
		}

		// SA-R 데이터 동기화
		function goDataSync() {
			var params = {
				"machine_seq": $M.getValue("machine_seq"),
			}
			$M.goNextPageAjaxMsg("동기화하시겠습니까?",this_page + '/sync', $M.toGetParam(params), {method: 'POST'},
					function (result) {
						if (result.success) {
							location.reload();
						}
					}
			);
		}

		// 수정
		function goModify() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["machine_name", "body_no"]}) == false) {
				return;
			}
			;

			var saleDate = $M.getValue("sale_dt");
			var custName = $M.getValue("cust_name");
			if (saleDate != "") {
				if (custName == "") {
					alert("차주명은 필수입니다.");
					return;
				}
			}

			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm), {method: 'POST'},
					function (result) {
						if (result.success) {
							alert("수정이 완료되었습니다.");
							location.reload();
						}
					}
			);
		}

		function goRemove() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["machine_seq"]}) == false) {
				return;
			}
			;

			$M.goNextPageAjaxRemove(this_page + '/remove', $M.toValueForm(frm), {method: 'POST'},
					function (result) {
						if (result.success) {
							alert("삭제가 완료되었습니다.");
							fnClose();
							window.opener.goSearch();
						}
					}
			);
		}

		function fnClose() {
			window.close();
		}

		//그리드생성
		function createMiddleAUIGrid() {
			var gridPros = {
				rowIdField: "codeId",
				height: 300,
				// rowNumber
				showRowNumColumn: false,
				editable: true

			};
			// 컬럼레이아웃
			var columnLayout = [
				{
					headerText: "부품번호",
					dataField: "part_no",
					width: "20%",
					style: "aui-center",
					editable: false
				},
				{
					headerText: "부품명",
					dataField: "part_name",
					style: "aui-left",
					editable: false
				},
				{
					headerText: "단위",
					dataField: "part_unit",
					width: "20%",
					style: "aui-center",
					editable: false
				},
				{
					headerText: "구성수량",
					dataField: "qty",
					width: "18%",
					style: "aui-center",
					editable: false
				},
			];
			auiGridMid = AUIGrid.create("#auiGridMid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridMid, ${optList});
			AUIGrid.bind(auiGridMid, "cellClick", function (event) {
				// 보낼 데이터
				var params = {
					'testParam1': 'param1',
					'testParam2': 'param2'
				};
			});
			$("#auiGridMid").resize();
		}

		//그리드생성
		function createCapAUIGrid() {
			var gridPros = {
				rowIdField: "codeId",
				height: 300,
				// rowNumber
				showRowNumColumn: false,
				editable: true

			};
			// 컬럼레이아웃
			var columnLayout = [
				{
					headerText: "차수",
					dataField: "cap_cnt",
					width: "10%",
					style: "aui-center",
					editable: false
				},
				{
					headerText: "예정일",
					dataField: "plan_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "25%",
					style: "aui-center",
					editable: false,
					// styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					// 	if (item.job_dt == "") {
					// 		return "aui-popup"
					// 	}
					// }
				},
				{
					headerText: "정비일",
					dataField: "job_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "25%",
					style: "aui-center aui-popup",
					editable: false
				},
				{
					headerText: "담당자",
					dataField: "reg_mem_name",
					width: "20%",
					style: "aui-center",
					editable: false
				},
				{
					headerText: "상태",
					dataField: "cap_status_name",
					style: "aui-center aui-popup",
					editable: false
				},
				{
					headerText: "사용여부",
					dataField: "use_yn",
					visible: false
				},
				{
					headerText: "장비일련번호",
					dataField: "machine_seq",
					visible: false
				},
				{
					headerText: "정비지시서번호",
					dataField: "job_report_no",
					visible: false
				}
			];

			auiGridCap = AUIGrid.create("#auiGridCap", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCap, ${capList});
			AUIGrid.bind(auiGridCap, "cellClick", function (event) {
				// if (event.dataField == "plan_dt" && event.item.job_dt == "") {
				// 	var param = {
				// 		"machine_seq": event.item["machine_seq"],
				// 		"seq_no": event.item["seq_no"],
				// 	};
				//
				// 	var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=300, left=0, top=0";
				// 	$M.goNextPage('/sale/sale0205p03', $M.toGetParam(param), {popupStatus: popupOption});
				// }
				if (event.dataField == 'job_dt' && event.item.job_dt != "") {

					var jobEdDt = event.item["job_dt"];
					if (jobEdDt == "") {
						alert("정비일이 존재하지 않습니다.");
						return;
					}

					var param = {
						"s_job_report_no": event.item.job_report_no
					};

					var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=1000, left=0, top=0";
					$M.goNextPage('/serv/serv0101p01', $M.toGetParam(param), {popupStatus: popupOption});
				}

				if (event.dataField == "cap_status_name") {
					var params = {
						"s_machine_seq": event.item.machine_seq,
						"s_cap_cnt": event.item.cap_cnt
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=500, left=0, top=0";
					$M.goNextPage('/serv/serv0101p15', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
			$("#auiGridCap").resize();
		}

		//그리드생성
		function createSARLocAUIGrid() {
			var gridPros = {
				rowIdField: "loc_date",
				height: 100,
				// rowNumber
				showRowNumColumn: true
			};
			// 컬럼레이아웃
			var columnLayout = [
				{
					headerText: "조회일자",
					dataField: "sar_loc_dt",
					dataType: "date",
					width: "120",
					minWidth: "120",
					formatString: "yyyy-mm-dd HH:MM",
					style: "aui-center",
					editable: false
				},
				{
					headerText: "위치",
					dataField: "sar_loc",
					width: "200",
					minWidth: "200",
					style: "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return item.loc_addr;
					},
					editable: false
				},
				{
					headerText: "시동상태",
					dataField: "sar_status",
					width: "100",
					minWidth: "100",
					style: "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == "1") {
							return "ON";
						} else if(value == "2") {
							return "OFF"
						} else {
							return ""
						}
					},
					editable: false
				}
			];

			auiGridSARLoc = AUIGrid.create("#auiGridSARLoc", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridSARLoc, ${sarLocList});
			AUIGrid.bind(auiGridSARLoc, "cellClick", function (event) {
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
				var params = {
						"lat": event.item.sar_loc.split('/')[0],
						"lng": event.item.sar_loc.split('/')[1]
				}
				$M.goNextPage('/naverCloud/naverMap', $M.toGetParam(params), {popupStatus: popupOption});
			});
			$("#auiGridSARLoc").resize();
		}
		function createSARErrorAUIGrid(){
			var gridPros = {
					rowIdField: "sar_error_no",
					height: 100,
					// rowNumber
					showRowNumColumn: true
				};
				// 컬럼레이아웃
				var columnLayout = [
					{
						headerText: "발생일자",
						dataField: "error_date",
						dataType: "date",
						width: "120",
						minWidth: "120",
						formatString: "yyyy-mm-dd HH:MM",
						style: "aui-center",
						editable: false
					},
					{
						headerText: "발생위치",
						dataField: "find_loc",
						width: "200",
						minWidth: "200",
						style: "aui-center aui-popup",
						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
							return item.find_place;
						},
						editable: false
					},
					{
						headerText: "에러내용",
						dataField: "error_text",
						width: "300",
						minWidth: "300",
						style: "aui-left",
						editable: false,
					},
					{
						headerText: "전화상담일자",
						dataField: "as_no",
						style: "aui-center aui-popup",
						width: "100",
						minWidth: "100",
						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
							if(value == "") {
								return "일지등록";
							} else {
								return item.as_dt
							}
						},
						editable: false
					},
					{
						headerText: "정비일자",
						dataField: "job_report_no",
						style: "aui-center aui-popup",
						width: "100",
						minWidth: "100",
						labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
							if(value == "") {
								return "정비지시서 작성";
							} else {
								return item.job_dt
							}
						},
						editable: false
					},
					{
						headerText: "처리결과",
						dataField: "job_status_cd",
						style: "aui-center",
						width: "70",
						minWidth: "70",
						editable: false
					},
					{
						headerText: "담당자",
						dataField: "charge_mem_name",
						width: "70",
						minWidth: "70",
						style: "aui-center",
						editable: false
					},
				];

				auiGridSARError = AUIGrid.create("#auiGridSARError", columnLayout, gridPros);
				AUIGrid.setGridData(auiGridSARError, ${sarErrorList});
				AUIGrid.bind(auiGridSARError, "cellClick", function (event) {
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
					if (event.dataField == "as_no") {
						var params = {
								"as_call_type_cd" : "0",
						};
						if (event.item.as_no == "") {
							params.s_machine_seq = $M.getValue("machine_seq");
							params.sar_error_no = event.item.sar_error_no;
							$M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus: popupOption});
						} else {
							params.s_as_no = event.item.as_no;
							$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
						}
					}

					if (event.dataField == "job_report_no") {
						var params = {
		                };
						if (event.item.job_report_no == "") {
							params.machine_seq =  $M.getValue("machine_seq");
							params.cust_no = $M.getValue("cust_no");
							params.sar_error_no = event.item.sar_error_no;
		                    $M.goNextPage('/serv/serv010101', $M.toGetParam(params), {popupStatus: popupOption});
						} else {
							params.s_job_report_no = event.item.job_report_no;
		                    $M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
						}
					}

					if(event.dataField == "find_loc"){
						var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
						var params = {
								"lat": event.item.find_loc.split('/')[0],
								"lng": event.item.find_loc.split('/')[1]
						}
						$M.goNextPage('/naverCloud/naverMap', $M.toGetParam(params), {popupStatus: popupOption});
					}
				});
				$("#auiGridSARError").resize();
		}

		function setHandoverMemNo(row) {
			var param = {
				handover_mem_no: row.mem_no,
				handover_mem_name: row.mem_name,
			}
			$M.setValue(param);
		}

		// 21.09.07 (SR : 10302) 입고센터 지정 장비대장등록과 상세 동일하게 변경.
		// 보유점(입고센터) Setting
		function setOrgMapCenterPanel(data) {
			$M.setValue("in_org_code", data.org_code);
			$M.setValue("in_org_name", data.org_name);
		}


		// SA-R 운행정보 팝업
		function goSarOperationMap(type) {
			var popupOption = "";
			var params = {
				s_type : type,
				machine_seq : ${list.machine_seq}
			}
			$M.goNextPage('/sale/sale0205p04', $M.toGetParam(params), {popupStatus: popupOption});
		}
		
		function goSvcCoworkPopup() {
			var param = {
				"machine_doc_no" : $M.getValue("machine_doc_no"),
				"free_cost_amt" : $M.setComma($M.toNum("${svc.free_cost_amt}"))
			};
			var popupOption = "";
			$M.goNextPage('/serv/serv0501p19', $M.toGetParam(param), {popupStatus: popupOption});
		}

		// 장비차주변경 정보
		function fnSetMachineCust(data) {
			$M.setValue("cust_name", data.cust_name);
			$M.setValue("cust_no", data.cust_no);
			$M.setValue("real_hp_no", data.hp_no);
			$M.setValue("hp_no", data.hp_no);
			$M.setValue("breg_name", data.breg_name);

			$M.setValue("__s_cust_no", data.cust_no);
			$M.setValue("__s_cust_name", data.cust_name);
			$M.setValue("__s_hp_no", data.hp_no);
		}

		// 업무DB 오픈
		function openWorkDB(){
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			var machineSeq = $M.getValue("machine_seq");
			if(machineSeq == ''){
				alert("장비번호가 없습니다.");
				return;
			}

			openWorkDBPanel(machineSeq, machinePlantSeq);
		}

		// 제출서류
		// 파일첨부팝업
		function goFileUploadPopup(type) {
			var param = {
				upload_type : 'MC',
				file_type : 'both',
				file_ext_type : 'pdf#img',
				max_size : 5000
			}
			submitType = type+"";
			openFileUploadPanel('fnSetFile', $M.toGetParam(param));
		}

		// 파일세팅
		function fnSetFile(file) {
			var str = '';
			str += '<div class="table-attfile-item submit_' + submitType + '">';
			if (file.file_ext == "pdf") {
				str += '<a href="javascript:fileDownload(' + file.file_seq + ');">' + file.file_name + '</a>&nbsp;';
			} else {
				str += '<a href="javascript:fnLayerImage(' + file.file_seq + ');">' + file.file_name + '</a>&nbsp;';
			}
			str += '<input type="hidden" name="file_seq_'+submitType+'" value="' + file.file_seq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(\'' +  submitType + '\')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.submit_'+submitType+'_div').append(str);
			$("#btn_submit_"+submitType).remove();
		}

		// 파일삭제
		function fnRemoveFile(type) {
			console.log(type);
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".submit_" + type).remove();
				var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup(\''+type+'\')" id="btn_submit_'+type+'">파일찾기</button>'
				$('.submit_'+type+'_div').append(str);
			} else {
				return false;
			}
		}

		// 서류저장
		function goSaveSubmit() {

			<c:if test="${fileModifyAuthYn ne 'Y'}">
				alert("서류를 수정할수있는 권한이 없습니다.");
				return false;
			</c:if>

			var machineDocNo = $M.getValue("machine_doc_no");

			var param = {};
			var codeArr = [];
			var fileSeqArr = [];
			// param["mch_sale_doc_file_cd"] = code;

			var array = codeMapDocFileArray.filter(function(value) {
				return value.code_v1 == "출고";
			});

			console.log("array : ", array);

			for (var i = 0; i < array.length; ++i) {
				var code = array[i].code_value;
				if (code != '10') {
					var fileSeq = $M.getValue("file_seq_"+code);
					if (fileSeq != "") {
						codeArr.push(code);
						fileSeqArr.push(fileSeq);
					} else {
						codeArr.push(code);
						fileSeqArr.push("0");
					}
				}
			}

			if (fileSeqArr.length == 0) {
				alert("저장할 파일이 없습니다.");
				return false;
			}

			param["mch_sale_doc_file_cd_str"] = $M.getArrStr(codeArr);
			param["file_seq_str"] = $M.getArrStr(fileSeqArr);

			console.log("$M.toGetParam(param) : ", $M.toGetParam(param));

			$M.goNextPageAjaxSave("/sale/sale0101p01/"+machineDocNo+"/submit", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
			);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="machine_seq" id="machine_seq" value="${list.machine_seq}">
<input type="hidden" name="machine_plant_seq" id="machine_plant_seq" value="${list.machine_plant_seq}">
<input type="hidden" name="machine_out_ye" id="machine_out_ye" value="${list.machine_out_ye}">
<input type="hidden" name="__s_machine_seq" id="__s_machine_seq" value="${list.machine_seq}">
<input type="hidden" name="cust_no" id="cust_no" value="${list.cust_no}">
<input type="hidden" name="__s_cust_no" id="__s_cust_no" value="${list.cust_no}">
<input type="hidden" name="__s_cust_name" id="__s_cust_name" value="${list.cust_name}">
<input type="hidden" name="__s_hp_no" id="__s_hp_no" value="${list.hp_no}">
<input type="hidden" name="change_dt" id="change_dt" value="${list.change_dt}">
<input type="hidden" name="cap_use_yn" id="cap_use_yn" value="${lastCapInfo.cap_use_yn}">
<input type="hidden" name="cap_cnt" id="cap_cnt" value="${lastCapInfo.cap_cnt}">
<input type="hidden" name="machine_change_dt" id="machine_change_dt">
<input type="hidden" name="machine_cust_no" id="machine_cust_no">
<input type="hidden" name="org_type" id="org_type" value="${org_type}">
<input type="hidden" name="grade_cd" id="grade_cd" value="${grade_cd}">
<input type="hidden" name="job_cd" id="job_cd" value="${SecureUser.job_cd}">
<input type="hidden" name="decal_model" id="decal_model" value="${sarDataMap.decal_model}">
<input type="hidden" name="machine_num" id="machine_num" value="${sarDataMap.machine_num}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<h4>장비대장상세</h4>
			</div>
<!-- 상단 폼테이블 -->
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="285px">
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">장비모델</th>
						<td>
							<div class="form-row inline-pd pr">
								<div class="col-5">
									<div class="input-group">
										<input type="text" name="machine_name" id="machine_name" class="form-control width120px" readonly="readonly" alt="장비모델" value="${list.machine_name}">
									</div>
								</div>
								<div class="col-auto">
									<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
										<jsp:param name="li_machine_type" value="__repair_history#__repair_amt#__as_todo#__campaign#__change_cust_history#__change_cust"/>
									</jsp:include>
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" id="btnChangeCust" name="btnChangeCust" onclick="javascript:__goChangeCust();">장비차주변경</button>
								</div>
							</div>
						</td>
						<th class="text-right">엔진모델1</th>
						<td>
							<div class="input-group">
								<input type="text" name="engine_model_1" id="engine_model_1" class="form-control" value="${list.engine_model_1}">
							</div>
						</td>
						<th class="text-right">연식</th>
						<td>
							<select class="form-control width80px" id="made_year" name="made_year">
								<option value="">- 선택 -</option>
								<c:forEach var="i" begin="1990" end="${inputParam.s_current_year}" step="1">
									<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
									<option value="${year_option}" <c:if test="${year_option eq list.made_year}">selected</c:if>>${year_option}년</option>
								</c:forEach>
							</select>
						</td>
<%--						<th class="text-right">엔진모델2</th>--%>
<%--						<td>--%>
<%--							<div class="input-group">--%>
<%--								<input type="text" name="engine_model_2" id="engine_model_2" class="form-control" value="${list.engine_model_2}">--%>
<%--							</div>--%>
<%--						</td>--%>
						<th class="text-right">옵션모델1</th>
						<td>
							<div class="input-group">
								<input type="text" name="opt_model_1" id="opt_model_1" class="form-control" value="${list.opt_model_1}">
							</div>
						</td>
						<th class="text-right">옵션모델2</th>
						<td>
							<div class="input-group">
								<input type="text" name="opt_model_2" id="opt_model_2" class="form-control" value="${list.opt_model_2}">
							</div>
						</td>
						<tr>
							<th class="text-right essential-item">차대번호</th>
							<td>
								<div class="d-flex">
									<input type="text" name="body_no" id="body_no" class="form-control essential-bg mr5" required="required" alt="차대번호" value="${list.body_no}">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
								</div>
							</td>
							<th class="text-right">엔진번호1</th>
							<td>
								<input type="text" name="engine_no_1" id="engine_no_1" class="form-control" value="${list.engine_no_1}">
							</td>
							<th class="text-right"></th>
							<td></td>
<%--							<th class="text-right">엔진번호2</th>--%>
<%--							<td>--%>
<%--								<input type="text" name="engine_no_2" id="engine_no_2" class="form-control" value="${list.engine_no_2}">--%>
<%--							</td>--%>
							<th class="text-right">옵션번호1</th>
							<td>
								<input type="text" name="opt_no_1" id="opt_no_1" class="form-control" value="${list.opt_no_1}">
							</td>
							<th class="text-right">옵션번호2</th>
							<td>
								<input type="text" name="opt_no_2" id="opt_no_2" class="form-control" value="${list.opt_no_2}">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">차주명</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-6">
										<div class="input-group width120px">
											<input type="text" name="cust_name" id="cust_name" class="form-control border-right-0 essential-bg" alt="차주명" value="${list.cust_name}">
											<button type="button" class="btn btn-icon btn-primary-gra" disabled="disabled" onclick="javascript:openSearchCustPanel('setCustInfo');"><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div class="col-6">
                                    	<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
                                        	<jsp:param name="li_type" value="__ledger#__sms_popup#__sms_info#__visit_history#__check_required#__have_machine_cust"/>
                                    	</jsp:include>
                                	</div>
									<!-- /연관업무 버튼 마우스 오버시 레이어팝업 -->
								</div>
							</td>
							<th class="text-right">휴대폰</th>
							<td>
								<div class="input-group">
									<input type="text" name="hp_no" id="hp_no" class="form-control border-right-0 width100px" format="phone" maxlength="11" readonly="readonly" value="${list.hp_no}">
									<button type="button" class="btn btn-icon btn-primary-gra"  onclick="javascript:fnSendSms('cust');"><i class="material-iconsforum"></i></button>
								</div>
							</td>
							<th class="text-right">업체명</th>
							<td>
								<input type="text" name="breg_name" id="breg_name" class="form-control" readonly="readonly" value="${list.breg_name}">
							</td>
							<th class="text-right">장비기사명</th>
							<td>
								<input type="text" name="driver_name" id="driver_name" class="form-control width100px" value="${list.driver_name}">
							</td>
							<th class="text-right">정비기사휴대폰</th>
							<td>
								<div class="input-group">
									<input type="text" name="driver_hp_no" id="driver_hp_no" class="form-control border-right-0 width100px" placeholder="숫자만 입력" format="phone" maxlength="11" value="${list.driver_hp_no}">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms('driver');"><i class="material-iconsforum"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">입고번호</th>
							<td>
								<input type="text" name="machine_lc_no" id="machine_lc_no" class="form-control" value="${list.machine_lc_no}" readonly="readonly">
							</td>
							<th class="text-right">입고일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" disabled="disabled" id="in_dt" name="in_dt" dateformat="yyyy-MM-dd" value="${list.in_dt}">
								</div>
							</td>
							<th class="text-right">분실구분</th>
							<td>
								<select name="type_cd" id="type_cd" class="form-control">
									<option>정상</option>
									<option>분실신고</option>
								</select>
							</td>
							<th class="text-right">입고처리</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" disabled="disabled" id="in_proc_date" name="in_proc_date" dateformat="yyyy-MM-dd" value="${list.in_proc_date}">
								</div>
							</td>
							<th class="text-right">판매일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="sale_dt" name="sale_dt" dateformat="yyyy-MM-dd" alt="판매일" value="${list.sale_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">출하번호</th>
							<td>
								<input type="text" name="machine_doc_no" id="machine_doc_no" class="form-control" readonly="readonly" value="${list.machine_doc_no}">
							</td>
							<th class="text-right">출하일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" disabled="disabled" id="out_dt" name="out_dt" dateformat="yyyy-MM-dd" value="${list.out_dt}">
								</div>
							</td>
							<th class="text-right">출하구분</th>
							<td>
								<select id="machine_status_cd" name="machine_status_cd" class="form-control">
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['MACHINE_STATUS']}" var="item">
										<option value="${item.code_value}" ${item.code_value == list.machine_status_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">출하처리</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="out_proc_date" name="out_proc_date" dateformat="yyyy-MM-dd" alt="출하처리" value="${list.out_proc_date}">
								</div>
							</td>
							<th class="text-right">등록서류</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" disabled="disabled" id="paper_dt" name="paper_dt" dateformat="yyyy-MM-dd" value="${list.paper_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">출하가능</th>
							<td colspan="5">
								<div class="form-row inline-pd">
									<div class="col-2">
										<select id="machine_out_pos_status_cd" name="machine_out_pos_status_cd" class="form-control width80px">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MACHINE_OUT_POS_STATUS']}" var="item">
												<option value="${item.code_value}" ${item.code_value == list.machine_out_pos_status_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
											</c:forEach>
										</select>
									</div>
									<div class="col-auto"> 정비완료예정일 </div>
									<div class="col-2">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="repair_finish_dt" name="repair_finish_dt" dateformat="yyyy-MM-dd" value="${list.repair_finish_dt}">
										</div>
									</div>
									<div class="col-auto"> 참고사항 </div>
									<div class="col-4">
										<input type="text" name="remark" id="remark" class="form-control" value="${list.remark}">
									</div>
								</div>
							</td>
							<th class="text-right">등록번호</th>
							<td>
								<div class="input-group">
									<input type="text" name="paper_mng_no" id="paper_mng_no" class="form-control" value="${list.paper_mng_no}">
								</div>
							</td>
							<th class="text-right">계산서일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="taxbill_dt" name="taxbill_dt" dateformat="yyyy-MM-dd" value="${list.taxbill_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">
								장비운영구분<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show()" onmouseout="javascript:hide()"></i></th>
								<!-- 연관업무 버튼 마우스 오버시 레이어팝업 -->
								<div class="con-info" id="machine_operation" style="max-height: 300px; left: 6%; top: 20%; width: 320px; display: none">
									<ul class="">
										<li>장비운영 구분은 자사가 고객 장비를 분류하는 기준이지 실 고객의 번호판의 색상과는 관계없음. 아래의 기준에 따라 고객의 장비 운영 종류를 [구분 / 선택]하십시오.</li>
										<li>마케팅 - 장비로 임대 (월대, 날일)를 뛰는 고객 (철거, 관로 등), 즉 장비를 가지고 가서 일하고 돈 받는 고객</li>
										<li>자가 - 임대업자가 아닌 자신의 사업분야가 있어 (건축사무소, 조경, 농업 등) 장비를 사용하는 고객</li>
										<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
										<%--<li>대리점 - 대리점이 보유한 장비</li>--%>
										<li>위탁판매점 - 위탁판매점이 보유한 장비</li>
										<li>미 관리 - 고객의 사유로 자사에서 관리가 불가한 장비(연락불가, 망실 등)</li>
										<li>관리금지 - 회사에서 관리를 금지한 장비로, 부품, 서비스 응대하면 안되는 장비</li>
									</ul>
								</div>
								<!-- /연관업무 버튼 마우스 오버시 레이어팝업 -->
							<td colspan="1">
								<div class="form-row inline-pd pr">
									<div class="col-auto">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_op_type_cd_n" name="mch_op_type_cd" <c:if test="${list.mch_op_type_cd == 'N'}">checked="checked"</c:if> value="N">
											<label class="form-check-label" for="mch_op_type_cd_n">미정</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_op_type_cd_s" name="mch_op_type_cd" <c:if test="${list.mch_op_type_cd == 'S'}">checked="checked"</c:if> value="S">
											<label class="form-check-label" for="mch_op_type_cd_s">자가</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_op_type_cd_b" name="mch_op_type_cd" <c:if test="${list.mch_op_type_cd == 'B'}">checked="checked"</c:if> value="B">
											<label class="form-check-label" for="mch_op_type_cd_b">영업</label><%-- (Q&A 21432) '영업' 문구 유지 --%>
										</div>
										<%-- B D F 추가 / 2023.03.27 --%>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_op_type_cd_d" name="mch_op_type_cd" <c:if test="${list.mch_op_type_cd == 'D'}">checked="checked"</c:if> value="D">
											<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
											<%--<label class="form-check-label" for="mch_op_type_cd_d">대리점</label>--%>
											<label class="form-check-label" for="mch_op_type_cd_d">위탁판매점</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_op_type_cd_m" name="mch_op_type_cd" <c:if test="${list.mch_op_type_cd == 'M'}">checked="checked"</c:if> value="M">
											<label class="form-check-label" for="mch_op_type_cd_m">미관리</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_op_type_cd_f" name="mch_op_type_cd" <c:if test="${list.mch_op_type_cd == 'F'}">checked="checked"</c:if> value="F">
											<label class="form-check-label" for="mch_op_type_cd_f">관리금지</label>
										</div>
									</div>
<%--									<div class="col-8">--%>
<%--										<button type="button" class="btn btn-primary-gra relative-work-hover" onmouseover="javascript:show()" onmouseout="javascript:hide()"><i class="material-iconsinfo text-primary"></i>장비운영구분이란</button>--%>
<%--									</div>--%>
								</div>
							</td>
							<%-- 22.11.11 (SR : 16466) 장비용도 추가 --%>
							<th class="text-right">장비용도</th>
							<td colspan="3">
								<div class="form-row inline-pd " style="padding-left : 5px; margin-right: 10px;">
									<input type="text" class="form-control" alt="장비용도" style="width : 230px;"
										   id="mch_use_cd"
										   name="mch_use_cd"
										   easyui="combogrid"
										   easyuiname="machineUseGroupCodeList"
										   idfield=code
										   textfield="code_name"
										   multi="N"
										   value="${list.mch_use_cd}"
									/>
									<div class="col-6" style="margin-left : 10px;">
										<input type="text" name="mch_use_text" id="mch_use_text" class="form-control" value="${list.mch_use_text}" placeholder="장비용도 설명 작성">
									</div>
								</div>
							</td>
							<th class="text-right">장비계약</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-auto">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_type_cad_d" name="mch_type_cad" disabled="disabled" <c:if test="${list.mch_type_cad == 'D'}">checked="checked"</c:if> value="D">
											<label class="form-check-label" for="mch_type_cad_d">미정</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_type_cad_c" name="mch_type_cad" disabled="disabled" <c:if test="${list.mch_type_cad == 'C'}">checked="checked"</c:if> value="C">
											<label class="form-check-label" for="mch_type_cad_c">건설기계</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="mch_type_cad_a" name="mch_type_cad" disabled="disabled" <c:if test="${list.mch_type_cad == 'A'}">checked="checked"</c:if> value="A">
											<label class="form-check-label" for="mch_type_cad_a">농기계</label>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">보유점</th>
<!-- 							<td> -->
<!-- 								<select class="form-control width100px" name="in_org_code" id="in_org_code"> -->
<!-- 									<option value="">- 전체 -</option> -->
<%-- 									<c:forEach var="warehouseList" items="${codeMap['WAREHOUSE']}"> --%>
<%-- 										<option value="${warehouseList.code_value}" <c:if test="${list.in_org_code == warehouseList.code_value}">selected="selected"</c:if> >${warehouseList.code_name}</option> --%>
<%-- 									</c:forEach> --%>
<!-- 								</select> -->
<!-- 							</td> -->
<!-- 21.09.07 (SR : 10302) 입고센터 지정 장비대장등록과 상세 동일하게 변경. -->
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0 width120px" name="in_org_name" id="in_org_name" readonly="readonly" alt="입고센터" value="${list.in_org_name}">
										<input type="hidden" name="in_org_code" id="in_org_code" value="${list.in_org_code}">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapPanel('setOrgMapCenterPanel');"><i class="material-iconssearch"></i></button>
									</div>
								</td>
						</tr>
						<tr>
							<th class="text-right">관리담당</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-auto"> 담당센터 </div>
									<div class="col-2">
										<input type="text" name="center_org_name" id="center_org_name" class="form-control width120px" readonly="readonly" value="${list.center_org_name}">
										<input type="hidden" name="center_org_code" id="center_org_code" value="${list.center_org_code}">
									</div>
									<div class="col-auto"> 서비스담당 </div>
									<div class="col-2">
										<input type="text" name="service_mem_name" id="service_mem_name" class="form-control width120px" readonly="readonly" value="${list.service_mem_name}">
										<input type="hidden" name="service_mem_no" id="service_mem_no" value="${list.service_mem_no}">
									</div>
									<div class="col-auto"> 미수담당 </div>
									<div class="col-2">
										<input type="text" name="misu_mem_name" id="misu_mem_name" class="form-control width120px" readonly="readonly" value="${list.misu_mem_name}">
										<input type="hidden" name="misu_mem_no" id="misu_mem_no" value="${list.misu_mem_no}">
									</div>
								</div>
							</td>
							<th class="text-right">QR 등록여부</th>
							<td>
								<div id="qr_image" name="qr_image">
									<input type="hidden" id="qr_no" name="qr_no" value="${list.qr_no}">
								</div>
							</td>
							<th class="text-right">비고</th>
							<td colspan="3">
								<div class="input-group">
									<input type="text" name="note_txt" id="note_txt" class="form-control" value="${list.note_txt}">
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /상단 폼테이블 -->
<!-- 하단 폼테이블 -->
			<div class="row">
<!-- 점검이력 -->
				<div class="col-4">
					<div class="title-wrap mt10">
						<h4>점검이력</h4>
					</div>
					<table class="table-border doc-table mt5">
						<colgroup>
							<col width="25%">
							<col width="25%">
							<col width="25%">
							<col width="25%">
						</colgroup>
						<thead>
						<tr>
							<th class="title-bg">점검구분</th>
							<th class="title-bg">점검일</th>
							<th class="title-bg">점검자</th>
							<th class="title-bg">비고</th>
						</tr>
						</thead>
						<tbody>
						<tr>
							<th>인도점검</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="handover_dt" name="handover_dt" dateformat="yyyy-MM-dd" value="${list.handover_dt}">
								</div>
							</td>
							<td>
								<input type="hidden" class="form-control" id="handover_mem_no" name="handover_mem_no" readonly="readonly" value="${list.handover_mem_no}">
								<div class="input-group">
									<input type="text" class="form-control border-right-0" id="handover_mem_name" name="handover_mem_name" readonly="readonly" value="${list.handover_mem_name}" style="background: white">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('setHandoverMemNo');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<td>
								<input type="text" class="form-control" id="handover_remark" name="handover_remark" value="${list.handover_remark}">
							</td>
						</tr>
						<tr>
							<th>DI Call</th>
							<td>
								<input type="text" class="form-control text-center" id="c_1_as_dt" name="c_1_as_dt" readonly="readonly" dateformat="yyyy-MM-dd" value="${call_1.as_dt}">
							</td>
							<td>
								<input type="text" class="form-control text-center" id="c_1_reg_mem_name" name="c_1_reg_mem_name" readonly="readonly" value="${call_1.reg_mem_name}">
							</td>
							<td>
								<c:if test="${call_1 ne null}">
									<button class="btn btn-primary-gra" style="width: 100%" onclick="javascript:goAsType('C', '${call_1.as_no}');">전화상담일지</button>
								</c:if>
							</td>
						</tr>
						<tr>
							<th>종료 Call</th>
							<td>
								<input type="text" class="form-control text-center" id="c_3_as_dt" name="c_3_as_dt" readonly="readonly" dateformat="yyyy-MM-dd" value="${call_3.as_dt}">
							</td>
							<td>
								<input type="text" class="form-control text-center" id="c_3_reg_mem_name" name="c_3_reg_mem_name" readonly="readonly" value="${call_3.reg_mem_name}">
							</td>
							<td>
								<c:if test="${call_3 ne null}">
									<button class="btn btn-primary-gra" style="width: 100%" onclick="javascript:goAsType('C', '${call_3.as_no}');">전화상담일지</button>
								</c:if>
							</td>
						</tr>
						<tr>
							<th>출고점검</th>
							<td>
								<input type="text" class="form-control text-center" id="doc_as_dt" name="doc_as_dt" dateformat="yyyy-MM-dd" readonly="readonly" value="${repair_o.as_dt}">
							</td>
							<td>
								<input type="text" class="form-control text-center" id="doc_reg_mem_name" name="doc_reg_mem_name" readonly="readonly" value="${repair_o.reg_mem_name}">
							</td>
							<td>
								<c:if test="${repair_o ne null}">
									<button class="btn btn-primary-gra" style="width: 100%" onclick="javascript:goAsType('O', '${repair_o.as_no}');">출하일지</button>
								</c:if>
							</td>
						</tr>
						<tr>
							<th>납입점검</th>
							<td>
								<input type="text" class="form-control text-center" id="pay_as_dt" name="pay_as_dt" dateformat="yyyy-MM-dd" readonly="readonly" value="${repair_r_1.as_dt}">
							</td>
							<td>
								<input type="text" class="form-control text-center" id="pay_reg_mem_name" name="pay_reg_mem_name" readonly="readonly" value="${repair_r_1.reg_mem_name}">
							</td>
							<td>
								<c:if test="${repair_r_1 ne null}">
									<button class="btn btn-primary-gra" style="width: 100%"  onclick="javascript:goAsType('R', '${repair_r_1.as_no}');">정비일지</button>
								</c:if>
							</td>
						</tr>
						<tr>
							<th>초기점검</th>
							<td>
								<input type="text" class="form-control text-center" id="early_as_dt" name="early_as_dt" dateformat="yyyy-MM-dd" readonly="readonly" value="${repair_r_2.as_dt}">
							</td>
							<td>
								<input type="text" class="form-control text-center" id="early_reg_mem_name" name="early_reg_mem_name" readonly="readonly" value="${repair_r_2.reg_mem_name}">
							</td>
							<td>
								<c:if test="${repair_r_2 ne null}">
									<button class="btn btn-primary-gra" style="width: 100%" onclick="javascript:goAsType('R', '${repair_r_2.as_no}');">정비일지</button>
								</c:if>
							</td>
						</tr>
						<tr>
							<th>종료점검</th>
							<td>
								<input type="text" class="form-control text-center" id="finish_as_dt" name="finish_as_dt" dateformat="yyyy-MM-dd" readonly="readonly" value="${repair_r_3.as_dt}">
							</td>
							<td>
								<input type="text" class="form-control text-center" id="finish_reg_mem_name" name="finish_reg_mem_name" readonly="readonly" value="${repair_r_3.reg_mem_name}">
							</td>
							<td>
								<c:if test="${repair_r_3 ne null}">
									<button class="btn btn-primary-gra" style="width: 100%" onclick="javascript:goAsType('R', '${repair_r_3.as_no}');">정비일지</button>
								</c:if>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
<!-- 부품내역 -->
				<div class="col-4">
					<div class="title-wrap mt10">
						<h4>부품내역</h4>
						<select id="opt_list" name="opt_list" class="form-control width80px">
						</select>
					</div>
					<div id="auiGridMid" style="margin-top: 5px; height: 300px;"></div>
				</div>
<!-- /부품내역 -->
<!-- CAP이력 -->
				<div class="col-4">
					<div class="title-wrap mt10">
						<h4>CAP이력</h4>
						<button type="button" class="btn btn-default" onclick="javascript:goCapLog();">CAP변경이력</button>
					</div>

<!-- 검색영역 -->
					<div class="search-wrap mt5">
						<table class="table">
							<colgroup>
								<col width="80px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>CAP적용여부</th>
									<td>
										<div class="input-group">
											<input type="radio" name="cap_use_yn" id="cap_use_y" value="Y" <c:if test="${ list.cap_yn eq 'Y'}">checked</c:if> onclick="javascript:goApplyInfo();" />
											<label for="cap_use_y">적용</label>
											<input type="radio" name="cap_use_yn" id="cap_use_n" value="N" <c:if test="${ list.cap_yn eq 'N'}">checked</c:if> onclick="javascript:goRemoveCap();" />
											<label for="cap_use_n">미적용</label>
										</div>
									</td>
									<td>
<%--										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>--%>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->

					<div id="auiGridCap" style="margin-top: 5px; height: 110px;"></div>
<!-- 서비스비용내역 -->
					<div>
						<div class="title-wrap mt5">
							<h4>서비스 비용 내역</h4>
						</div>
						<table class="table-border doc-table mt5">
							<colgroup>
								<col width="25%">
								<col width="25%">
								<col width="25%">
								<col width="25%">
							</colgroup>
							<thead>
							<tr>
								<th class="title-bg">구분</th>
								<th class="title-bg">책정금액</th>
								<th class="title-bg">사용금액</th>
								<th class="title-bg">사용내역</th>
							</tr>
							</thead>
							<tbody>
							<tr>
								<th>출하비용</th>
								<td class="text-right">
									<span><fmt:formatNumber type="number" maxFractionDigits="3" value="${svc.out_cost_amt}" /></span>
								</td>
								<td class="text-right">
									<%-- <span><fmt:formatNumber type="number" maxFractionDigits="3" value="${svc.out_use_amt}" /></span> --%>
									<span><fmt:formatNumber type="number" maxFractionDigits="3" value="${repair_o ne null ? svc.out_cost_amt : 0}" /></span>
								</td>
								<td class="text-center">
									<c:if test="${repair_o ne null}">
										<span class="pointer underline" onclick="javascript:goAsType('O', '${repair_o.as_no}');">출하일지</span>
									</c:if>
								</td>
							</tr>
							<tr>
								<th>무상정비비용</th>
								<td class="text-right">
<%--									<span><fmt:formatNumber type="number" maxFractionDigits="3" value="${svc.free_cost_amt}" /></span>--%>
									<c:choose>
										<c:when test="${svc.coworker_yn eq 'Y'}">
											<span class="pointer underline" onclick="javascript:goSvcCoworkPopup();"><fmt:formatNumber type="number" maxFractionDigits="3" value="${svc.free_cost_amt}" /></span>
										</c:when>
										<c:otherwise>
											<span><fmt:formatNumber type="number" maxFractionDigits="3" value="${svc.free_cost_amt}" /></span>
										</c:otherwise>
									</c:choose>
								</td>
								<td class="text-right">
									<span><fmt:formatNumber type="number" maxFractionDigits="3" value="${svc.free_use_amt}" /></span>
								</td>
								<td class="text-center">
									<span class="pointer underline" onclick="javascript:goFreeAsList();">무상 <fmt:formatNumber type="number" maxFractionDigits="3" value="${svc.free_cnt}" />건</span>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
				</div>
<!-- /CAP이력 -->
			</div>
<!-- /하단 폼테이블 -->
<!-- SA-R 상세  -->
			<c:if test="${machineSarMap != null}">
				<div class="title-wrap mt10">
					<h4>SA-R 계약정보</h4>
				</div>
				<div>
					<table class="table-border mt5">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">SA-R 계약번호</th>
							<td colspan="3">
								<input type="text" name="contract_no" id="contract_no" class="form-control width160px" readonly="readonly"  value="${machineSarMap.contract_no}">
							</td>
							<th class="text-right">개통여부</th>
							<td colspan="3">
								<c:forEach items="${codeMap['MACHINE_SAR_STATUS']}" var="item">
									<div class="form-check form-check-inline v-align-middle">
										<input type="radio" id="${item.code_value}" name="machine_sar_status_cd" class="form-check-input" value="${item.code_value}" <c:if test="${machineSarMap.machine_sar_status_cd eq item.code_value}">checked="checked"</c:if> >
										<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
									</div>
								</c:forEach>
							</td>
							<th class="text-right">비고</th>
							<td colspan="3">
								<input type="text" name="sar_remark" id="sar_remark" class="form-control text-left"  value="${machineSarMap.sar_remark}" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">개통일자</th>
							<td colspan="3">
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="contract_st_dt" name="contract_st_dt" dateformat="yyyy-MM-dd" alt="개통일자" disabled="disabled" value="${machineSarMap.contract_st_dt}">
								</div>
							</td>
							<th class="text-right">거래처코드</th>
							<td colspan="3">
								<input type="text" name="cust_deal_no" id="cust_deal_no" class="form-control width180px" readonly="readonly" value="${machineSarMap.cust_deal_no}">
							</td>
							<th class="text-right">고객이메일</th>
							<td colspan="3">
								<input type="text" name="cust_email" id="cust_email" class="form-control width180px" readonly="readonly" value="${machineSarMap.cust_email}">
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- SA-R 월별 가동시간 -->
	            <div>
	                <div class="title-wrap mt10">
	                    <h4>SA-R 월별 가동시간 [총 가동시간(SA-R):${sarDataMap.run_time}]</h4>
						<div>
						최종 동기화 시간 : ${sarDataMap.upt_date}
	                    <button type="button" class="btn btn-default" onclick="javascript:goDataSync();">데이터 동기화</button>
						</div>
	                </div>
	                <table class="table-border doc-table mt5">
	                    <colgroup>
	                        <col width="">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                        <col width="6.66%">
	                    </colgroup>
	                    <thead>
	                        <tr>
	                            <th class="title-bg">년도</th>
	                            <th class="title-bg">1월</th>
	                            <th class="title-bg">2월</th>
	                            <th class="title-bg">3월</th>
	                            <th class="title-bg">4월</th>
	                            <th class="title-bg">5월</th>
	                            <th class="title-bg">6월</th>
	                            <th class="title-bg">7월</th>
	                            <th class="title-bg">8월</th>
	                            <th class="title-bg">9월</th>
	                            <th class="title-bg">10월</th>
	                            <th class="title-bg">11월</th>
	                            <th class="title-bg">12월</th>
	                            <th class="title-bg">합계</th>
	                            <th class="title-bg">누적</th>
	                        </tr>
	                    </thead>
	                    <tbody>
	                    <c:forEach var="map" items="${sarOpTimeMonList}">
	                    	<tr>
	                    		<td class="text-center">${map.op_year }</td>
	                    		<td class="text-right">${map.mon_01 }</td>
	                    		<td class="text-right">${map.mon_02 }</td>
	                    		<td class="text-right">${map.mon_03 }</td>
	                    		<td class="text-right">${map.mon_04 }</td>
	                    		<td class="text-right">${map.mon_05 }</td>
	                    		<td class="text-right">${map.mon_06 }</td>
	                    		<td class="text-right">${map.mon_07 }</td>
	                    		<td class="text-right">${map.mon_08 }</td>
	                    		<td class="text-right">${map.mon_09 }</td>
	                    		<td class="text-right">${map.mon_10 }</td>
	                    		<td class="text-right">${map.mon_11 }</td>
	                    		<td class="text-right">${map.mon_12 }</td>
	                    		<td class="text-right">${map.total }</td>
	                    		<td class="text-right">${map.run_time }</td>
	                    	</tr>
	                    </c:forEach>
	                    </tbody>
	                </table>
	            </div>
				<!-- /SA-R 월별 가동시간 -->
				<!-- 하단 폼테이블 -->
	            <div class="row">
					<!-- SA-R 에러코드 -->
	                <div class="col-8">
	                    <div class="title-wrap mt10">
	                        <h4>SA-R 에러코드</h4>
	                        <button type="button" class="btn btn-default" onclick="javascript:goSarOperationMap('ERROR');">에러정보</button>
	                    </div>
	                    <div id="auiGridSARError" style="margin-top: 5px; height: 100px;"></div>
	                </div>
					<!-- /SA-R 에러코드 -->
					<!-- SA-R 위치정보 -->
	                <div class="col-4">
	                    <div class="title-wrap mt10">
	                        <h4>SA-R 위치정보</h4>
	                        <button type="button" class="btn btn-default" onclick="javascript:goSarOperationMap('OPERATION');">운행정보</button>
	                    </div>
	                    <div id="auiGridSARLoc" style="margin-top: 5px; height: 100px;"></div>
	                </div>
				<!-- /SA-R 위치정보 -->
	            </div>
				<!-- /하단 폼테이블 -->
			</c:if>
<!-- SA-R 상세 -->

<!-- 제출서류 -->
			<c:if test="${not empty docFileList}">
				<div class="title-wrap mt10">
					<h4>제출서류</h4>
					<c:if test="${fileModifyAuthYn eq 'Y'}">
						<div>
							<span class="text-warning" tooltip="">※ [서류저장] 버튼을 눌러야 첨부파일이 저장됩니다.</span>
							<button type="button" class="btn btn-info" onclick="javascript:goSaveSubmit()">서류저장</button>
								<%--						<c:if test="${page.add.ACNT_MNG_YN eq 'Y' or page.fnc.F00111_001 eq 'Y'}">--%>
								<%--							<button type="button" class="btn btn-info" onclick="javascript:goConfirmSubmit()">서류확인</button>--%>
								<%--						</c:if>--%>
						</div>
					</c:if>
				</div>
				<div>
					<table class="table-border mt5">
						<colgroup>
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-center" colspan="5">출고 전 제출서류</th>
							<th class="text-center" colspan="3">출고 후 제출서류</th>
						</tr>
						<tr>
							<c:forEach var="item" items="${docFileList}">
								<th>${item.code_name}</th>
							</c:forEach>
						</tr>
						<tr>
							<c:forEach var="item" items="${docFileList}">
								<c:if test="${not empty item.file_seq and item.mch_sale_doc_file_cd ne '12'}">
<%--									<td class="text-center underline" onclick="javascript:fileDownload(${item.file_seq})">${item.origin_file_name}</td>--%>
									<td>
										<a href="javascript:fileDownload(${item.file_seq})">${item.origin_file_name }</a>
									</td>
								</c:if>

								<c:if test="${empty item.file_seq and item.mch_sale_doc_file_cd ne '12'}">
									<td></td>
								</c:if>

								<c:if test="${item.mch_sale_doc_file_cd eq '12'}">
									<c:if test="${modusignFileYn eq 'Y'}">
										<c:if test="${not empty item.file_seq}">
											<td>
												<a href="javascript:fileDownload(${item.file_seq})">${item.origin_file_name }</a>
												<input type="hidden" name="file_seq_${item.mch_sale_doc_file_cd}" value="${item.file_seq }">
											</td>
										</c:if>
										<c:if test="${empty item.file_seq}">
											<td>
												고객확인중
											</td>
										</c:if>
<%--										<td>--%>
<%--											<a href="javascript:fileDownload(${item.file_seq})">${item.origin_file_name }</a>--%>
<%--											<input type="hidden" name="file_seq_${item.mch_sale_doc_file_cd}" value="${item.file_seq }">--%>
<%--										</td>--%>
									</c:if>

									<c:if test="${modusignFileYn eq 'N'}">
										<td>
											<div class="table-attfile submit_${item.mch_sale_doc_file_cd}_div">
												<c:if test="${not empty item.origin_file_name }">
													<div class="table-attfile-item submit_${item.mch_sale_doc_file_cd}">
														<a href="javascript:fileDownload(${item.file_seq})">${item.origin_file_name }</a>
														<input type="hidden" name="file_seq_${item.mch_sale_doc_file_cd}" value="${item.file_seq }">
														<c:if test="${item.pass_ypn ne 'Y' and fileModifyAuthYn eq 'Y'}">
															<button type="button" class="btn-default" onclick="javascript:fnRemoveFile('${item.mch_sale_doc_file_cd}')"><i class="material-iconsclose font-18 text-default"></i></button>
														</c:if>
													</div>
												</c:if>
												<c:if test="${empty item.origin_file_name and fileModifyAuthYn eq 'Y'}">
													<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('${item.mch_sale_doc_file_cd}')" id="btn_submit_${item.mch_sale_doc_file_cd}">파일찾기</button>
												</c:if>
											</div>
										</td>
									</c:if>
								</c:if>
							</c:forEach>
						</tr>
						</tbody>
					</table>
				</div>
			</c:if>
<!-- 제출서류 -->
			<c:if test="${not empty docFileList}">
<%--				<div class="title-wrap mt10">--%>
<%--					<h4>제출서류</h4>--%>
<%--				</div>--%>
				<div>
					<table class="table-border mt5">
						<colgroup>
							<col width="">
							<col width="">
							<col width="">
							<col width="">
<%--							<col width="">--%>
<%--							<col width="">--%>
<%--							<col width="">--%>
<%--							<col width="">--%>
						</colgroup>
						<tbody>
<%--						<tr>--%>
<%--							<th class="text-center" colspan="5">출고 전 제출서류</th>--%>
<%--							<th class="text-center" colspan="3">출고 후 제출서류</th>--%>
<%--						</tr>--%>
						<tr>
							<c:forEach var="item" items="${assistFileList}">
								<th>${item.code_name}</th>
							</c:forEach>
							<c:forEach var="item" items="${commissioningFileList}">
								<th>${item.code_name}</th>
							</c:forEach>
						</tr>
						<tr>
							<c:forEach var="item" items="${assistFileList}">
								<c:if test="${not empty item.file_seq}">
<%--									<td class="text-center underline" onclick="javascript:fileDownload(${item.file_seq})">${item.origin_file_name}</td>--%>
									<td>
										<a href="javascript:fileDownload(${item.file_seq})">${item.origin_file_name }</a>
<%--										<input type="hidden" name="file_seq_${item.mch_sale_doc_file_cd}" value="${item.file_seq }">--%>
									</td>
								</c:if>

								<c:if test="${empty item.file_seq}">
									<td></td>
								</c:if>
							</c:forEach>
							<c:forEach var="item" items="${commissioningFileList}">
<%--								<c:if test="${not empty item.file_seq}">--%>
<%--									<td class="text-center underline" onclick="javascript:fileDownload(${item.file_seq})">${item.origin_file_name}</td>--%>
<%--								</c:if>--%>

<%--								<c:if test="${empty item.file_seq}">--%>
<%--									<td></td>--%>
<%--								</c:if>--%>
								<td>
									<div class="table-attfile submit_${item.mch_sale_doc_file_cd}_div">
										<c:if test="${not empty item.origin_file_name }">
											<div class="table-attfile-item submit_${item.mch_sale_doc_file_cd}">
												<a href="javascript:fileDownload(${item.file_seq})">${item.origin_file_name }</a>
												<input type="hidden" name="file_seq_${item.mch_sale_doc_file_cd}" value="${item.file_seq }">
												<c:if test="${item.pass_ypn ne 'Y' and fileModifyAuthYn eq 'Y'}">
													<button type="button" class="btn-default" onclick="javascript:fnRemoveFile('${item.mch_sale_doc_file_cd}')"><i class="material-iconsclose font-18 text-default"></i></button>
												</c:if>
											</div>
										</c:if>
										<c:if test="${empty item.origin_file_name and fileModifyAuthYn eq 'Y' }">
											<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('${item.mch_sale_doc_file_cd}')" id="btn_submit_${item.mch_sale_doc_file_cd}">파일찾기</button>
										</c:if>
									</div>
								</td>
							</c:forEach>
						</tr>
						</tbody>
					</table>
				</div>
			</c:if>

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
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
