<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > Stock의뢰서상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

    var auiGrid_part;
    var auiGrid_option;
    var auiGrid_memo;

	var parentPaidList; // 유상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)
	var parentFreeList; // 무상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)

	var isMachine = false;

	var centerAddr;

	var statusCd = ${stock.machine_doc_status_cd}

	$(document).ready(function() {
		createAUIGrid();
		fnSetInit();
	});

	function goPlanTiPopup() {
		var planDt = $M.getValue("receive_plan_dt");
		if (planDt == "") {
			alert("출하 예정일자를 선택해주세요.");
			$("#receive_plan_dt").focus();
			return false;
		}
		var outOrgCode = $M.getValue("out_org_code");
		// 센터가 지정되지않으면(기타센터) 모든 시간 가능 -> 출하지가 센터가 아니기때문에 시간관리 못함!
		/* if (outOrgCode == "") {
			alert("출하센터를 선택해주세요.");
			$("#out_org_code").focus();
			return false;
		} */
    	var params = {
	   		"parent_js_name" : "fnSetPlanTi",
			"s_receive_plan_dt" : planDt,
			"s_out_org_code" : outOrgCode,
			"s_machine_out_doc_seq" : "${outDoc.machine_out_doc_seq}", // 같은 출하의뢰서면 취소했다가 다시 설정할 수 있도록함
		}

		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=480, left=0, top=0";
		$M.goNextPage('/sale/sale0101p16', $M.toGetParam(params), {popupStatus: poppupOption});
	}

	function fnSetPlanTi(row) {
		console.log(row);
		var ti1 = row.code.substr(0, 2);
		var ti2 = row.code.substr(2, 4);
		$M.setValue("receive_plan_ti_1", ti1);
		$M.setValue("receive_plan_ti_2", ti2);

		var tempTi = ti1+"시 "+ti2+"분";
		$M.setValue("receive_plan_ti_temp", tempTi);
	}

	function goCheckSaleDoc() {
		var param = {
			machine_doc_no : "${stock.machine_doc_no}"
		}
		$M.goNextPageAjax(this_page+"/checkStockDoc", $M.toGetParam(param), {method : 'GET'},
				function(result) {
			    	if(result.success) {
			    		if (result.machine_doc_no != null) {
			    			var machineDocNo = result.machine_doc_no;
			    			if (confirm("이미 작성된 품의서("+machineDocNo+")가 있습니다.\n이동하시겠습니까?") == false){
			    				return false;
			    			}
			    			var param = {
			    				machine_doc_no : machineDocNo
			    			}
			    			$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param));
			    		} else {
			    			var param = {
		    					machineDocYn : "Y"
			    			}
			    			openSearchCustPanel('goNewDoc', $M.toGetParam(param));
			    		}
					}
				}
			);
	}

	function goNewDoc(row) {
		var param = {
			cust_no : row.cust_no,
			machine_doc_no : "${stock.machine_doc_no}"
		}
		$M.goNextPageAjax(this_page+"/saleDoc", $M.toGetParam(param), {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		alert("처리가 완료됐습니다.");
			    		var param = {
		    				machine_doc_no : result.machine_doc_no
		    			}
		    			$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param));
					}
				}
			);
	}

	function goPartoutPage() {
		var params = {
			"machine_out_doc_seq" : "${stock.machine_out_doc_seq}",
			"parent_js_name" : "fnCalcNoOutAfterPartOut",
		}
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=480, left=0, top=0";
		$M.goNextPage('/part/part0203p04', $M.toGetParam(params), {popupStatus: poppupOption});
	}

	// 부품출고처리 후 콜백
	function fnCalcNoOutAfterPartOut(data) {
		var row = data;
		if (row == null || row == undefined) {
			return false;
		}
		var rowIndexs = AUIGrid.getRowIndexesByValue(auiGrid_part, "part_seq_no", row.out_seq_no);
		if (rowIndexs != null) {
			rowIndexs = rowIndexs[0];
			var rows = AUIGrid.getGridData(auiGrid_part);
			var temp = rows[rowIndexs];
			var no_out_qty = $M.toNum(temp.part_no_out_qty);
			if (row.no_out_operation == "-") { // 출고처리
				if (no_out_qty - row.qty > -1) {
					temp["part_no_out_qty"] = no_out_qty - row.qty;
				} else {
					console.error("미출고수량이 마이너스일 수 없음");
				}
			} else if (row.no_out_operation == "+") { //출고 취소
				if (no_out_qty + row.qty <= temp.part_qty) {
					temp["part_no_out_qty"] = no_out_qty + row.qty;
				} else {
					console.error("미출고수량이 출고수량을 초과함");
				}
			}
			AUIGrid.updateRowsById(auiGrid_part, temp);
			AUIGrid.resetUpdatedItems(auiGrid_part);
		} else {
			alert("미출고 행을 찾을 수 없음");
		}
	}

	function goStockPrint() {
		openReportPanel('sale/sale0101p09_01.crf','machine_doc_no=' + $M.getValue("machine_doc_no"));
	}

	function fnSetStockArrival(row) {
		var param = {
			arrival_post_no : row.zipNo,
			arrival_addr1 : row.roadAddr,
			arrival_addr2 : row.addrDetail
		}
		$M.setValue(param);
	}

	// 상신취소
	function goApprCancel() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}",
			appr_cancel_yn : "Y"
		};
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}

	function goApproval() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}"
		};
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}

	function fnChangeOutOrgCode() {
		var cd = $M.getValue("out_org_code");
		if (cd != "") {
			$M.setValue("out_post_no", centerAddr[cd][0]);
			$M.setValue("out_addr1", centerAddr[cd][1]);
		} else {
			$M.setValue("out_post_no", "");
			$M.setValue("out_addr1", "");
		}
		$M.setValue("receive_plan_ti_1", "00");
		$M.setValue("receive_plan_ti_2", "00");
		$M.setValue("receive_plan_ti_temp", "00시 00분");
	}

	function goApprovalResult(result) {
		if(result.appr_status_cd == '03') {
			alert("반려가 완료됐습니다.");
			location.reload();
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
			var form = $M.createForm();
			$M.setHiddenValue(form, 'appr_job_seq', $M.getValue("appr_job_seq"));
			var machineDocNo = $M.getValue("machine_doc_no");
			$M.goNextPageAjax(this_page+"/"+machineDocNo+"/approval", form, {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		alert("처리가 완료됐습니다.");
			    		location.reload();
					}
				}
			);
		}
	}

	function goMachineToOut() {
    	var param = {
    		machine_plant_seq : "${stock.machine_plant_seq}",
			out_org_code : $M.getValue("out_org_code"),
			parent_js_name : "fnSetMachineToOut",
			s_stock_yn : "Y"
		}
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=400, left=0, top=0";
		$M.goNextPage('/sale/sale0101p06', $M.toGetParam(param), {popupStatus : poppupOption});
    }

    function fnSetMachineToOut(row) {
    	var param = {
    		body_no : row.body_no,
    		engine_no_1 : row.engine_no_1,
    		machine_seq : row.machine_seq
    	}
    	$M.setValue(param);
    }

	function goRemove() {
		var machineDocNo = $M.getValue("machine_doc_no");
		$M.goNextPageAjaxRemove("/sale/sale0101p01/"+machineDocNo+"/remove", '', {method : 'POST'},
			function(result) {
		    	if(result.success) {
		    		// 여기서 뒤로가기
		    		alert("삭제에 성공했습니다.");
		    		fnClose();
		    		if (opener != null && opener.goSearch) {
		    			opener.goSearch();
		    		}
				}
			}
		);
	}

	function fnClose() {
		window.close();
	}

	function fnSetInit() {
		console.log(statusCd);
		switch (statusCd) {
		case 0 : $(".process2 :input").attr("disabled", true); break;
		case 1 : $(".process1 :input").attr("disabled", true); $(".process2 :input").attr("disabled", true); break;
		case 2 : $(".process1 :input").attr("disabled", true); $(".p2s").addClass("rs"); $(".p2b").addClass("rb"); break;
		case 3 : $(".process2 :input").attr("disabled", false);
		case 4 : $(".process1 :input").attr("disabled", true); $(".process2 :input").attr("disabled", true);
		case 5 : $(".process1 :input").attr("disabled", true); $(".process2 :input").attr("disabled", true); $("#btnOut").html("회수처리");
		case 6 : $(".process1 :input").attr("disabled", true); $(".process2 :input").attr("disabled", true);
		}
		if (statusCd < 2) {
			$("#_goPartPrint").css("display", "none");
		}
		if (statusCd < 2 || statusCd == 6) {
			$("#btnOut").css("display", "none");
		}
		if (statusCd == 2 && "${out_auth_yn}" != "Y") {
			$(".process2 :input").attr("disabled", true);
			 $(".p2s").removeClass("rs"); $(".p2b").removeClass("rb");
			$("#btnOut").css("display", "none");
		}
		centerAddr = new Object();
		var firstCd = "";
		<c:forEach items="${outOrgCodeList}" var="item" varStatus="status">
			if ("${item.org_code}" != "") {
				<c:if test="${status.first}">firstCd = "${item.org_code}"</c:if>
				centerAddr["${item.org_code}"] = ["${item.post_no}", "${item.addr1}"];
			}
		</c:forEach>
		console.log(${result});
		fnSetData(${result});

		if ($("#part_no_out_cnt").html() != "0" && statusCd == 5) {
			$("#btnAddPartOut").css("display", "block");
			$("#btnAddPartOut").attr("disabled", false);
		}
		if (statusCd == 2) {
			$("#btnPartOut").attr("disabled", false);
		}
		if (statusCd == 5 || statusCd == 6) {
			$("#_goApproval").css("display", "none");
		}

		$("#work_db_btn").attr("disabled", false);
	}

	function goAddPartPopup() {
		if ($M.getValue("machine_name") == "") {
			alert("모델명을 입력해주세요.");
			$("#machine_name").focus();
			return false;
		}
		parentFreeList = [];
		parentPaidList = [];
		var tempList = AUIGrid.exportToObject(auiGrid_part);
		for (var i = 0; i < tempList.length; i++) {
			var obj = new Object();
			for (var prop in tempList[i]) {
				obj[prop.substring(5,prop.length)] = tempList[i][prop];
			}
			if (obj['attach_yn'] != 'Y') {
				if (obj['free_yn'] === 'Y') {
					parentFreeList.push(obj);
				} else {
					parentPaidList.push(obj);
				}
			}
		}
		var param = {
    			cost_part_breg_no : $M.getValue("breg_no"), // 사업자번호
    			machine_plant_seq : $M.getValue("machine_plant_seq"),
    			page_type : "OUT"
    	}
    	openFreeAndPaidMachinePart('fnSetFreeAndPaidMachinePart', $M.toGetParam(param));
	}

    function fnSetFreeAndPaidMachinePart(list) {
    	var row = $.extend(true, [], list);
    	for (var i = 0; i < row.parentPaidList.length; ++i) {
	        	row.parentPaidList[i]['paid_free_yn'] = "N";
	        	row.parentPaidList[i]['paid_attach_yn'] = "N";
	        	row.parentPaidList[i]['paid_default_qty'] = row.parentPaidList[i].paid_default_qty == null ? 0 : row.parentPaidList[i]['paid_default_qty'];
	        	row.parentPaidList[i]['paid_add_qty'] = row.parentPaidList[i].paid_add_qty == null ? 0 : row.parentPaidList[i]['paid_add_qty'];
	        	row.parentPaidList[i]['paid_no_out_qty'] = row.parentPaidList[i].paid_no_out_qty == null ? 0 : row.parentPaidList[i]['paid_no_out_qty'];
	        	row.parentPaidList[i]['paid_use_yn'] = 'Y';
	        	row.parentPaidList[i]['paid_add_doc_yn'] = 'N';
	        	row.parentPaidList[i]['paid_doc_seq_no'] = row.parentPaidList[i].paid_doc_seq_no == null ? null : row.parentPaidList[i]['paid_doc_seq_no'];
	        	row.parentPaidList[i]['paid_qty'] = row.parentPaidList[i].paid_add_qty;
	        }

	        for (var i = 0; i <row.parentFreeList.length; ++i) {
	        	row.parentFreeList[i]['free_free_yn'] = "Y";
	        	row.parentFreeList[i]['free_attach_yn'] = "N";
	        	row.parentFreeList[i]['free_default_qty'] = row.parentFreeList[i].free_default_qty == null ? 0 : row.parentFreeList[i]['free_default_qty'];
	        	row.parentFreeList[i]['free_add_qty'] = row.parentFreeList[i].free_add_qty == null ? 0 : row.parentFreeList[i]['free_add_qty'];
	        	row.parentFreeList[i]['free_no_out_qty'] = row.parentFreeList[i].free_no_out_qty == null ? 0 : row.parentFreeList[i]['free_no_out_qty'];
	        	row.parentFreeList[i]['free_use_yn'] = 'Y';
	        	row.parentFreeList[i]['free_add_doc_yn'] = 'N';
	        	row.parentFreeList[i]['free_doc_seq_no'] = row.parentFreeList[i].free_doc_seq_no == null ? null : row.parentFreeList[i]['free_doc_seq_no'];
	        	row.parentFreeList[i]['free_qty'] = $M.toNum(row.parentFreeList[i].free_add_qty)+$M.toNum(row.parentFreeList[i].free_default_qty);
	        }
    	var tempList = AUIGrid.exportToObject(auiGrid_part);
    	var partList = [];
    	var concatPartList = [];
    	for (var i = 0; i < tempList.length; ++i) {
    		if (tempList[i].part_attach_yn === "Y") {
    			partList.push(tempList[i]);
    		}
    	}
    	concatPartList = row.parentFreeList.concat(row.parentPaidList);
    	for (var i = 0; i < concatPartList.length; i++) {
			var obj = new Object();
			for (var prop in concatPartList[i]) {
				var tempProp = "part"+prop.substring(4,prop.length);
				obj[tempProp] = concatPartList[i][prop];
			}
			// 신규저장이기때문에 바로 삭제
			if (obj.part_cmd != "D") {
				partList.push(obj);
			}
    	}
    	Array.isArray(partList) == true ? partList.sort($M.sortMulti("-part_no_out_qty")) : "";
    	AUIGrid.setGridData(auiGrid_part, partList);

    	// 신규저장이기 때문에 찍 처리 안함
		/* var prmArr = [];
		var pArr = AUIGrid.getGridData(auiGrid_part);
		for (var i = 0; i <  pArr.length; ++i) {
			if (pArr[i].part_cmd == "D") {
				prmArr.push(AUIGrid.rowIdToIndex(auiGrid_part, pArr[i]._$uid));
			}
		}
		AUIGrid.removeRow(auiGrid_part, prmArr); */

    	fnCalcNoOutQty();
    }

    function fnCalcNoOutQty() {
        var partLength = 0;
        var part = AUIGrid.getGridData(auiGrid_part);
        var noOutQty = 0;
        for (var i = 0; i < part.length; ++i) {
        	if ($M.toNum(part[i].part_no_out_qty) != 0) {
        		noOutQty+=1;
        	}
        	if (part[i].part_cmd != "D") {
        		partLength+=1;
        	}
        }
        $("#part_total_cnt").html(partLength);
        $("#part_no_out_cnt").html(noOutQty);
    }

	function goModelInfoClick() {
		if (isMachine == true && confirm("모델을 다시 조회하면 입력한 값이 초기화됩니다.\n다시 조회하시겠습니까?") == false) {
			return false;
		}
		var param = {
			s_price_present_yn : "Y"
		};
		openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
	}

	function fnSetModelInfo(row) {
		$M.goNextPageAjax("/machine/stock/"+row.machine_plant_seq, "", {method : 'GET'},
			function(result) {
	    		if(result.success) {
	    			 alert("모델을 변경했습니다.");
	    			 isMachine = true;
	    			 $M.setValue("machine_name", row.machine_name);
	    			 $M.setValue("machine_plant_seq", row.machine_plant_seq);
	    			 fnSetData(result);
				}
			}
		);
	}

	function fnSetData(result) {
		$("#btnAddPart").css("display", "block");
		// 선택사항
		var optList = result.optionList;
		var optCode = $("#opt_code");
		optCode.html("");
		AUIGrid.setGridData("#auiGrid_option", []);
	  	optCode.css("display", "none");
	  	if (optList) {
	  		if (optList.length > 0) {
				optCode.css("display", "inline-block");
				var selectedOptCode = null;
				var selectedOptCodeIdx = 0;
				for (var i = 0; i < optList.length; ++i) {
					optCode.append("<option value='"+optList[i].opt_code+"'>"+optList[i].opt_name+"</option>");
					if (optList[i].opt_code == selectedOptCode) {
						selectedOptCodeIdx = i;
					}
				}
				if (selectedOptCode != null) {
					$M.setValue("opt_code", selectedOptCode);
				} else {
					$M.setValue("opt_code", optList[0].opt_code);
				}
				AUIGrid.setGridData("#auiGrid_option", optList[selectedOptCodeIdx].list);
			}
	  	}
		// 지급품목
		var partList = [];
		AUIGrid.setGridData("#auiGrid_part", []);
		if (result.freeList) {
			AUIGrid.setGridData("#auiGrid_part", result.freeList);
		}
		if (result.memoList) {
			AUIGrid.setGridData("#auiGrid_memo", result.memoList);
		}
		fnCalcNoOutQty();
	}

	function fnChangeOpt() {
		var opt = $M.getValue("opt_code");
		var tempOptList = [];
		for (var i = 0; i < optList.length; ++i) {
			if (optList[i].opt_code == opt) {
				tempOptList = optList[i].list;
			}
		}
		AUIGrid.setGridData("#auiGrid_option", tempOptList);
	}

	function fnSetOutAddr(row) {
		var param = {
			out_post_no : row.zipNo,
			out_addr1 : row.roadAddr,
			out_addr2 : row.addrDetail
		}
		$M.setValue(param);
	}

	function fnSetArrivalAddr(row) {
		var param = {
			arrival1_post_no : row.zipNo,
			arrival1_addr1 : row.roadAddr,
			arrival1_addr2 : row.addrDetail
		}
		$M.setValue(param);
	}

	function goRequestApproval() {
		if ($M.getValue("machine_plant_seq") == "") {
			alert("모델을 선택해주세요");
			return false;
		}
		var param = {
			out_org_code : $M.getValue("out_org_code"),
			machine_plant_seq : $M.getValue("machine_plant_seq")
		}
		$M.goNextPageAjax("/sale/sale010102/cnt", $M.toGetParam(param), {method : 'GET', loader : false},
				function(result) {
			    	if(result.success) {
			    		console.log(result);
			    		if (result.cnt == 0) {
			    			alert("출고센터에 장비가 없습니다.");
			    		} else {
			    			goModify('appr');
			    		}
					}
				}
			);
	}

	function goOut() {
		if (statusCd < 2) {
			alert("결재 완료 후 처리하세요.");
			return false;
		}
		if (statusCd != 5) {
			// 필수 : 차대번호, 출고일자, 운송사, 연락처, 도착일시, 도착지, 운임
			if ($M.validation(document.main_form, {field:["body_no", "machine_send_cd", "out_dt", "arrival_dt",
				"arrival_area_name", "transport_cmp_cd",
				"transport_amt", "transport_tel_no"]}) == false) {
				return false;
			}
			var ti1 = $M.getValue("arrival_ti_1");
	    	var ti2 = $M.getValue("arrival_ti_2");
	    	if(ti1 == "00" && ti2 == "00") {
	    		alert("도착시간을 선택하세요");
	    		$("#arrival_ti_2").focus();
	    		return false;
	    	} else {
	    		$M.setValue("arrival_ti", ti1+ti2);
	    	}
		}
    	$M.setValue("save_mode", "out");
    	var msg = "출하처리하시겠습니까?\n처리 후 수정이 불가능합니다.";
    	if (statusCd == 5) {
    		msg = "회수처리하시겠습니까?\n처리 후 수정이 불가능합니다.";
    	}
    	goProcess(msg, "out");
	}

	function goAddOut() {
		var param = {
			machine_doc_no : "${stock.machine_doc_no}"
		}
		$M.goNextPageAjax(this_page+"/checkStockDoc", $M.toGetParam(param), {method : 'GET'},
				function(result) {
			    	if(result.success) {
			    		if (result.machine_doc_no != null) {
			    			var machineDocNo = result.machine_doc_no;
			    			if (confirm("이미 작성된 품의서("+machineDocNo+")가 있습니다.\n이동하시겠습니까?") == false){
			    				return false;
			    			}
			    			var param = {
			    				machine_doc_no : machineDocNo
			    			}
			    			$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param));
			    		} else {
			    			var param = {
		    					   machine_doc_no : "${stock.machine_doc_no}",
		    					   type : "add"
		    		        };
		    				var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=550, left=0, top=0";
		    		        $M.goNextPage('/sale/sale0101p11', $M.toGetParam(param), {popupStatus : poppupOption});
			    		}
					}
				}
			);
	}

	function goProcess(msg, control) {
		var machineDocNo = $M.getValue("machine_doc_no");
		var frm = $M.toValueForm(document.main_form);
		var concatCols = [];
		var concatList = [];

		// 바로 수정하므로 여기서 처리안함
		/* var addedMemoRows = AUIGrid.getAddedRowItems(auiGrid_memo);
		for (var i = 0; i < addedMemoRows.length; ++i) {
			var item = {
				m_seq_no : addedMemoRows[i].m_seq_no,
				m_cmd : "C"
			}
			AUIGrid.updateRowsById(auiGrid_memo, item);
		} */

		var gridIds = [auiGrid_option, auiGrid_part];
		for (var i = 0; i < gridIds.length; ++i) {
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}
		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);
		$M.goNextPageAjaxMsg(msg, this_page+"/"+machineDocNo+"/modify", gridFrm, {method : 'POST'},
			function(result) {
		    	if(result.success) {
		    		// 여기서 뒤로가기
		    		if (control != undefined) {
						if (control == "out") {
							var param = {
             					   machine_doc_no : "${stock.machine_doc_no}",
             					   type : "out"
             	            }
							if (statusCd == "5") {
								param["type"] = "recover";
							}
             	            var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=550, left=0, top=0";
             	            $M.goNextPage('/sale/sale0101p11', $M.toGetParam(param), {popupStatus : poppupOption});
             	           location.reload();
						} else {
							alert("처리가 완료됐습니다.");
							location.reload();
						}
		    		} else {
		    			alert("수정이 완료되었습니다.");
		    			location.reload();
		    		}
				}
			}
		);
	}

	function goModify(appr) {
		if ($M.validation(document.main_form) == false) {
			return false;
		}
		var ti1 = $M.getValue("receive_plan_ti_1");
    	var ti2 = $M.getValue("receive_plan_ti_2");
    	if(ti1 == "00" && ti2 == "00") {
    		alert("희망시간을 선택하세요");
    		$("#receive_plan_ti_1").focus();
    		return false;
    	} else {
    		$M.setValue("receive_plan_ti", ti1+ti2);
    	}
		$M.setValue("save_mode", "save");
		var msg = "수정하시겠습니까?";
		if (appr != undefined) {
			$M.setValue("save_mode", "appr");
			msg = "결재 요청 하시겠습니까?\n요청 후 수정이 불가능 합니다";
		}
		goProcess(msg, appr);
	}

	function fnSetDispOrgCd(row) {
		console.log(row);
		var param = {
			display_org_name : row.org_name,
			display_org_code : row.org_code
		}
		$M.setValue(param);
	}

	//그리드생성
	function createAUIGrid() {
		//그리드 생성 _ 지급품목
		var gridPros_product = {
			rowIdField : "_$uid",
			fillColumnSizeMode : false,
			editable: statusCd == 2 ? true : false,
			headerHeight : 20,
			rowHeight : 11,
			footerHeight : 20,
			rowStyleFunction : function(rowIndex, item) {
        		if ($M.toNum(item.part_no_out_qty) !== 0) {
					return "aui-color-red";
        		}
        	}
		};
		var visibles = false;
		var columnLayout_product = [
			{
        		dataField : "_$uid",
        		visible : visibles
        	},
        	{
        		dataField : "part_seq_no",
        		visible : visibles
        	},
			{
				headerText : "부품번호",
				dataField : "part_part_no",
				width : "30%",
				style : "aui-center",
				editable : false
			},
			{
				headerText : "부품명",
				dataField : "part_part_name",
				style : "aui-left",
				editable : false
			},
			{
				headerText : "수량",
				dataField : "part_qty",
				width : "10%",
				style : "aui-center",
				editable : false
			},
			{
				headerText : "미출고",
				dataField : "part_no_out_qty",
				width : "10%",
				editable : false
				/* editable: statusCd == 2 ? true : false,
				style : "aui-center",
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                    if (statusCd == "2" && $M.toNum(item.part_no_out_qty) == 0) {
                        return "aui-editable";
                    } else {
                        return "";
                    }
                },
				editRenderer: {
                    type: "InputEditRenderer",
                    onlyNumeric: true,
                    allowPoint: false,
                    validator: function (ov, nv, item, dataField) {
                        var newValue = parseInt(nv);
                        var oldValue = parseInt(ov);
                        var qty = parseInt(item.part_qty);
                        var msg = "";
                        var isValid = true;
                        if (newValue > qty) {
                            isValid = false;
                            msg = "수량보다 클 수 없습니다.";
                        } else {
                            isValid = true;
                        }
                        return {"validate": isValid, "message": msg};
                    }
                } */
			},
			{
                dataField: "part_attach_yn",
                visible: visibles
            },
            {
                dataField: "part_add_doc_yn",
                visible: visibles
            },
            {
                dataField: "part_machine_doc_no",
                visible: visibles
            },
            {
                dataField: "part_doc_seq_no",
                visible: visibles
            },
            {
                dataField: "part_default_qty",
                visible: visibles
            },
            {
                dataField: "part_add_qty",
                visible: visibles
            },
            {
                dataField: "part_free_yn",
                visible: visibles
            },
            {
                dataField: "part_unit_price",
                visible: visibles
            },
            {
                dataField: "part_total_amt",
                visible: visibles
            },
            {
                dataField: "part_use_yn",
                visible: visibles
            },
            {
            	dataField: "part_cmd",
            	visible: visibles
            }
		];
		auiGrid_part = AUIGrid.create("#auiGrid_part", columnLayout_product, gridPros_product);
		AUIGrid.setGridData(auiGrid_part, []);
		AUIGrid.bind(auiGrid_part, "cellEditEnd", function (event) {
        	if (event.dataField == "part_no_out_qty") {
        		fnCalcNoOutQty();
            }
        });
		$("#auiGrid_part").resize();
		//그리드 생성 _ 선택사항
		var gridPros_option = {
			rowIdField : "part_no",
			fillColumnSizeMode : false,
			editable: statusCd == 2 ? true : false,
			headerHeight : 20,
			rowHeight : 11,
			footerHeight : 20,
			height : 80
		};
		var columnLayout_option = [
			{
				dataField : "option_machine_plant_seq",
				visible : false
			},
			{
				dataField : "option_opt_code",
				visible : false
			},
			{
				headerText : "부품번호",
				dataField : "option_part_no",
				width : "20%",
				style : "aui-center",
				editable : false
			},
			{
				headerText : "부품명",
				dataField : "option_part_name",
				style : "aui-left",
				editable : false
			},
			{
				headerText : "수량",
				dataField : "option_qty",
				width : "10%",
				style : "aui-center",
				editable : false
			}/* ,
			{
				headerText : "미출고",
				dataField : "option_no_out_qty",
				width : "10%",
				editable: statusCd >= 2 ? true : false,
				style : "aui-center",
                editRenderer: {
                    type: "InputEditRenderer",
                    onlyNumeric: true,
                    allowPoint: false,
                    validator: function (ov, nv, item, dataField) {
                        var newValue = parseInt(nv);
                        var oldValue = parseInt(ov);
                        var qty = parseInt(item.option_qty);
                        var msg = "";
                        var isValid = true;
                        if (newValue > qty) {
                            isValid = false;
                            msg = "수량보다 클 수 없습니다.";
                        } else {
                            isValid = true;
                        }
                        return {"validate": isValid, "message": msg};
                    }
                }
			} */
		];
		auiGrid_option = AUIGrid.create("#auiGrid_option", columnLayout_option, gridPros_option);
		AUIGrid.setGridData(auiGrid_option, []);
		$("#auiGrid_option").resize();

		// 메모
		var gridPros_memo = {
			// rowIdField가 unique 임을 보장
			rowIdTrustMode : true,
			rowIdField : "m_seq_no",
			showStateColumn : false,
			fillColumnSizeMode : false,
			editable : true,
		};
		var columnLayout_memo = [
			{
				dataField : "m_seq_no",
				visible : false
			},
			{
				dataField : "m_machine_doc_no",
				visible : false
			},
			{
				dataField : "m_mem_no",
				visible : false
			},
			{
                dataField: "m_use_yn",
                visible: false
            },
            {
            	dataField: "m_cmd",
            	visible: false
            },
			{
				dataField : "gubun",
				headerText : "구분",
				editable : false,
				width : "40",
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '출하'
				},
			},
			{
				dataField : "m_reg_mem_name",
				headerText : "작성자",
				editable : false,
				width : "60",
			},
			{
				dataField : "m_memo_text",
				style : "aui-left",
				headerText : "특이사항",
				required : true,
				validator : AUIGrid.commonValidator,
				editable : true,
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "40",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						if (event.item.m_mem_no != "${SecureUser.mem_no}") {
							AUIGrid.showToastMessage(auiGrid_memo, event.rowIndex, event.columnIndex, "타인의 특이사항을 삭제할 수 없습니다.");
							return false;
						};
						var param = {
							machine_doc_no : $M.getValue("machine_doc_no"),
							seq_no : event.item.m_seq_no,
							cmd : "D"
						};
						$M.goNextPageAjaxRemove(this_page+"/memo", $M.toGetParam(param), {method : 'POST', loader : false},
								function(result) {
							    	if(result.success) {
							    		AUIGrid.removeRow(event.pid, event.rowIndex);
										AUIGrid.removeSoftRows(auiGrid_memo);
									}
								}
							);
					},
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false
			}
		];
		auiGrid_memo = AUIGrid.create("#auiGrid_memo", columnLayout_memo, gridPros_memo);
		AUIGrid.setGridData(auiGrid_option, []);
		$("#auiGrid_memo").resize();
		// 추가행 에디팅 진입 허용
		AUIGrid.bind(auiGrid_memo, "cellEditBegin", function (event) {
			if (event.item.m_mem_no != "${SecureUser.mem_no}") {
				setTimeout(function() {
					AUIGrid.showToastMessage(auiGrid_memo, event.rowIndex, event.columnIndex, "타인의 특이사항을 수정할 수 없습니다.");
				}, 1);
				return false;
			};
		});
		/* AUIGrid.bind(auiGrid_memo, "rowStateCellClick", function(event) {
			var param = {
					machine_doc_no : $M.getValue("machine_doc_no"),
					seq_no : event.item.m_seq_no,
					cmd : "D"
				};
				$M.goNextPageAjaxRemove(this_page+"/memo", $M.toGetParam(param), {method : 'POST', loader : false},
						function(result) {
					    	if(result.success) {
					    		AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.removeSoftRows(auiGrid_memo);
							}
						}
					);
		}); */
		AUIGrid.bind(auiGrid_memo, "cellEditEndBefore", function (event) {
			if (event.value == "") {
				setTimeout(function() {
					AUIGrid.showToastMessage(auiGrid_memo, event.rowIndex, event.columnIndex, "이 항목은 필수입니다. 삭제하려면 삭제버튼을 이용하세요.");
				}, 1);
				return event.oldValue;
			}
		});
		AUIGrid.bind(auiGrid_memo, "cellEditEndBefore", function (event) {
			if (event.value == "") {
				setTimeout(function() {
					AUIGrid.showToastMessage(auiGrid_memo, event.rowIndex, event.columnIndex, "이 항목은 필수입니다. 삭제하려면 삭제버튼을 이용하세요.");
				}, 1);
				return event.oldValue;
			}
		});
		AUIGrid.bind(auiGrid_memo, "cellEditEnd", function (event) {
			var param = {
				memo_text : event.value,
				machine_doc_no : $M.getValue("machine_doc_no"),
				seq_no : event.item.m_seq_no,
				cmd : "U"
			}
			$M.goNextPageAjax(this_page+"/memo", $M.toGetParam(param), {method : 'POST', loader : false},
					function(result) {
				    	if(result.success) {

						}
					}
				);
		});
	}

	function fnAdd() {
		var memoText= "메모를 입력하세요.";
		var param = {
			machine_doc_no : $M.getValue("machine_doc_no"),
			memo_text : memoText,
			cmd : "C",
			use_yn : "Y",
			reg_id : "${SecureUser.mem_no}"
		}
		$M.goNextPageAjax(this_page+"/memo", $M.toGetParam(param), {method : 'POST', loader : false},
				function(result) {
			    	if(result.success) {
			    		console.log(result);
			    		var obj = new Object();
			    		obj["m_seq_no"] = result.seq_no;
			    		obj["m_mem_no"] = "${SecureUser.mem_no}";
			    		obj["m_memo_text"] = memoText;
			    		obj["m_use_yn"] = "Y";
			    		obj["m_cmd"] = "C";
			    		obj["m_reg_mem_name"] = "${SecureUser.user_name}";
			    		AUIGrid.addRow(auiGrid_memo, obj, 'last');
					}
				}
			);
	}

	// 업무DB 연결 함수 21-08-65이강원
 	function openWorkDB(){
 		openWorkDBPanel('',$M.getValue("machine_plant_seq"));
 	}

	// 출하사항변경
	function goChangeOutInfo() {
		if ((statusCd == "5" || statusCd == "6") == false) {
			alert("출하완료된 자료가 아닙니다.");
			return false;
		}

		var param = {
			machine_out_doc_seq : $M.getValue("machine_out_doc_seq"),
			stock_yn : "Y"
		}
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=360, left=0, top=0";
		$M.goNextPage('/sale/sale0101p07', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	function fnReload() {
		window.location.reload();
	}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="appr_job_seq" value="${stock.appr_job_seq }">
<input type="hidden" name="machine_doc_no" value="${stock.machine_doc_no}">
<input type="hidden" name="machine_plant_seq" value="${stock.machine_plant_seq}">
<input type="hidden" name="machine_out_doc_seq" value="${stock.machine_out_doc_seq}">
<input type="hidden" name="machine_seq" value="${stock.machine_seq}">
<input type="hidden" name="mch_type_cad" value="D"> <!-- 스탁은 건기농기 설정안하는데, 필수라서 D로 설정함 -->

<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap half-print">
				<div class="doc-info" style="flex: 1;">
					<h4 class="primary" >Stock출하의뢰서</h4>
					<div>
						<button type="button" id="_goPartPrint" onclick="goStockPrint()" class="btn btn-md btn-rounded btn-outline-primary"><i class="material-iconsprint text-primary"></i>스탁출하의뢰서 인쇄</button>
					</div>
				</div>
<!-- 결재영역 -->
				<div style="margin-left: 5px;">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->
			</div>
<!-- 폼테이블 -->
				<div class="row mt7">
<!-- 좌측 폼테이블-->
					<div class="col-6 process1">
						<div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
							<div class="title-wrap">
									<h4>기본정보</h4>
									<div class="btn-group">
										<div class="right">${stock.reg_date } ${stock.doc_mem_name }</div>
									</div>
								</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
							<table class="table-border mt5">
									<colgroup>
										<col width="75px">
										<col width="">
										<col width="75px">
										<col width="">
									</colgroup>
									<tbody>
										<tr>
											<th class="text-right">관리번호</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-6">
														<input type="text" class="form-control" readonly="readonly" value="${fn:split(stock.machine_doc_no,'-')[0]}-${fn:split(stock.machine_doc_no,'-')[1]}">
													</div>
													<%-- <div class="col-auto">-</div>
													<div class="col-2">
														<input type="text" class="form-control" readonly="readonly" value="${fn:split(stock.machine_doc_no,'-')[1]}">
													</div> --%>
												</div>
											</td>
											<th class="text-right">상태</th>
											<td>
												${stock.machine_doc_status_name}
											</td>
										</tr>
										<tr>
											<th class="text-right rs">모델명</th>
											<td>
												<div class="form-row inline-pd pr">
													<div class="col-8">
														<div class="input-group">
															<input type="text" class="form-control border-right-0 width120px" name="machine_name" id="machine_name" value="${stock.machine_name }" readonly="readonly" required="required" alt="모델명">
															<input type="hidden" name="machine_plant_seq" id="machine_plant_seq">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goModelInfoClick();"><i class="material-iconssearch"></i></button>
														</div>
										            </div>
										            <div class="col-4">
										             	<c:if test="${page.fnc.F00120_001 eq 'Y'}">
								                        	<button type="button" id="work_db_btn" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
								                        </c:if>
										            </div>
												</div>
											</td>
											<th class="text-right rs">전시점</th>
											<td>
												<div class="input-group">
													<input type="text" class="form-control border-right-0 width120px" id="display_org_name" name="display_org_name" value="${stock.display_org_name}" readonly="readonly" required="required" alt="전시점">
													<input type="hidden" name="display_org_code" id="display_org_code" value="${stock.display_org_code}">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapPanel('fnSetDispOrgCd');"><i class="material-iconssearch"></i></button>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right rs">인도예정</th>
											<td>
												<div class="input-group">
													<input type="text" class="form-control border-right-0 rb calDate width120px" id="receive_plan_dt" name="receive_plan_dt" value="${stock.receive_plan_dt}" dateFormat="yyyy-MM-dd" required="required" alt="인도예정" onchange="fnChangeOutOrgCode()">
													<select class="form-control width100px" name="out_org_code" id="out_org_code" style="margin-left: 5px; border-radius: 4px;" onchange="fnChangeOutOrgCode()">
														<c:forEach var="item" items="${outOrgCodeList}">
		                                                    <option value="${item.org_code}" <c:if test="${item.org_code eq stock.out_org_code}">selected="selected"</c:if> >
		                                                            ${item.org_name}
		                                                    </option>
		                                                </c:forEach>
													</select>
												</div>
											</td>
											<th class="text-right">인수자</th>
											<td>
												<input type="text" class="form-control width120px" name="receive_user_name" id="receive_user_name" value="${stock.receive_user_name }" maxlength="30">
											</td>
										</tr>
										<tr>
											<th class="text-right rs">희망시간</th>
											<td>
												<div class="input-group">
													<c:if test="${not empty stock.receive_plan_ti}">
			                                			<input type="text" class="form-control border-right-0" style="max-width: 76px;" id="receive_plan_ti_temp" name="receive_plan_ti_temp" required="required" readonly="readonly" value="${fn:substring(stock.receive_plan_ti,0,2)}시 ${fn:substring(stock.receive_plan_ti,2,4)}분">
			                                		</c:if>
			                                		<c:if test="${empty stock.receive_plan_ti}">
			                                			<input type="text" class="form-control border-right-0" style="max-width: 76px;" id="receive_plan_ti_temp" name="receive_plan_ti_temp" required="required" readonly="readonly" value="">
			                                		</c:if>
			                                   		<input type="hidden" id="receive_plan_ti_1" name="receive_plan_ti_1" value="${fn:substring(stock.receive_plan_ti,0,2) }">
			                                   		<input type="hidden" id="receive_plan_ti_2" name="receive_plan_ti_2" value="${fn:substring(stock.receive_plan_ti,2,4) }">
			                                   		<button type="button" class="btn btn-icon btn-primary-gra" id="breg_search_btn" onclick="javascript:goPlanTiPopup()"><i class="material-iconssearch"></i></button>
			                                    </div>
											</td>
											<th class="text-right">연락처</th>
											<td>
												<input type="text" class="form-control width120px" id="receive_user_tel_no" name="receive_user_tel_no" format="tel" value="${stock.receive_user_tel_no}" maxlength="11">
											</td>
										</tr>
										<tr>
											<th class="text-right rs">출하지</th>
											<td colspan="3">
												<div class="form-row inline-pd">
													<div class="col-1 pdr0">
														<input type="text" class="form-control mw45" id="out_post_no" name="out_post_no" value="${stock.out_post_no}" readonly="readonly" required="required" alt="출하지">
													</div>
													<div class="col-auto pdl5" style="margin-left: 5px">
														<button type="button" class="btn btn-primary-gra" style="width: 100%;"  onclick="javascript:openSearchAddrPanel('fnSetOutAddr');">주소찾기</button>
													</div>
													<div class="col-5">
														<input type="text" class="form-control" id="out_addr1" name="out_addr1" value="${stock.out_addr1 }" readonly="readonly">
													</div>
													<div class="col-4">
														<input type="text" class="form-control" id="out_addr2" name="out_addr2" value="${stock.out_addr2 }">
													</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right rs">도착지</th>
											<td colspan="3">
												<div class="form-row inline-pd">
													<div class="col-1 pdr0">
														<input type="text" class="form-control mw45" id="arrival1_post_no" name="arrival1_post_no" value="${stock.arrival1_post_no }" readonly="readonly" required="required" alt="도착지 우편번호">
													</div>
													<div class="col-auto pdl5" style="margin-left: 5px">
														<button type="button" class="btn btn-primary-gra" style="width: 100%;"  onclick="javascript:openSearchAddrPanel('fnSetArrivalAddr');">주소찾기</button>
													</div>
													<div class="col-5">
														<input type="text" class="form-control" id="arrival1_addr1" name="arrival1_addr1" value="${stock.arrival1_addr1 }" readonly="readonly">
													</div>
													<div class="col-4">
														<input type="text" class="form-control" id="arrival1_addr2" name="arrival1_addr2" value="${stock.arrival1_addr2 }">
													</div>
												</div>
											</td>
										</tr>
									</tbody>
								</table>
						</div>
						<div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
							<div class="title-wrap mt10">
								<div class="title-sum">
									<h4>지급품목</h4>
									<div>전체 <span id="part_total_cnt">0</span>건 중 <span class="text-secondary"><span id="part_no_out_cnt">0</span>건</span>과부족</div>
								</div>
								<div>
									<c:if test="${stock.machine_doc_status_cd eq '2'}">
	                            		<span>부품출하에서 처리 시, 미출고 수량이 반영됩니다.</span>
	                            		<span><button type="button" id="btnPartOut" class="btn btn-info" onclick="javascript:goPartoutPage()">부품출고</button></span>
	                            	</c:if>
                            	</div>
								<c:if test="${stock.machine_doc_status_cd eq '0' }">
									<div>
										<button type="button" id="btnAddPart" style="display: none;" class="btn btn-default" onclick="javascript:goAddPartPopup()">추가출고처리</button>
									</div>
								</c:if>
								<c:if test="${stock.machine_doc_status_cd eq '5'}">
									<div>
										<button type="button" id="btnAddPartOut" class="btn btn-default" style="display: none;" onclick="javascript:goAddOut()">추가출고처리</button>
									</div>
								</c:if>
							</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
							<div id="auiGrid_part" style="margin-top: 5px;"></div>
						</div>

						<div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
							<div class="title-wrap mt10">
								<h4>옵션품목</h4>
								<div class="btn-group">
									<div class="right">
										<select name="opt_code" id="opt_code" style="height: 24px; display: none;" onchange="fnChangeOpt()"></select>
									</div>
								</div>
							</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
							<div id="auiGrid_option" style="margin-top: 5px;"></div>
						</div>

					</div>
<!-- 좌측 폼테이블-->
<!-- 우측 폼테이블-->
					<div class="col-6">
<!-- 출하사항 -->
						<div class="process2">
							<div class="title-wrap">
								<h4>출하사항</h4>
								<div class="right">${stock.out_proc_date } ${stock.out_mem_name }</div>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="15%">
									<col width="35%">
									<col width="25%">
									<col width="25%">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right p2s">차대번호</th>
										<td colspan="3">
											<div class="form-row inline-pd">
												<div class="col-6">
													<div class="input-group">
														<input type="text" class="form-control border-right-0" value="${stock.body_no}" id="body_no" name="body_no" alt="차대번호" readonly="readonly">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goMachineToOut();"><i class="material-iconssearch"></i></button>
													</div>
												</div>
												<div class="col-6">
													<input type="text" class="form-control" value="${stock.engine_no_1}" id="engine_no_1" name="engine_no_1" alt="엔진번호1" readonly="readonly">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right p2s">운송구분</th>
										<td>
											<select class="form-control rb width140px p2b" id="machine_send_cd" alt="운송구분"
		                                            name="machine_send_cd" required="required">
		                                        <option value="">- 선택 -</option>
		                                        <c:forEach var="item" items="${codeMap['MACHINE_SEND']}">
		                                            <option value="${item.code_value}"
		                                                    <c:if test="${stock.machine_send_cd == item.code_value}">selected="selected"</c:if>>
		                                                    ${item.code_name}
		                                            </option>
		                                        </c:forEach>
		                                    </select>
										</td>
										<th class="text-right p2s">출고일자</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate p2b" id="out_dt" name="out_dt" alt="출고일자" dateFormat="yyyy-MM-dd" value="${stock.out_dt }">
											</div>
										</td>
									</tr>
									<tr>
			                            <th class="text-right p2s">도착일자</th>
			                            <td>
			                                <div class="input-group width120px">
			                                    <input type="text" class="form-control border-right-0 calDate p2b" id="arrival_dt" name="arrival_dt" value="${stock.arrival_dt}" dateFormat="yyyy-MM-dd">
			                                </div>
			                            </td>
			                            <th class="text-right p2s">도착시간</th>
			                            <td>
			                                <div class="form-row inline-pd">
			                                   <div class="pl5">
			                                       <select class="form-control width45px p2b" id="arrival_ti_1" name="arrival_ti_1">
			                                           <option value="00">00</option>
			                                           <c:forEach var="ti" varStatus="i" begin="1" end="23" step="1">
			                                               <option value="<c:if test="${ti < 10}">0</c:if><c:out value="${ti}" />"
			                                                       <c:if test="${not empty stock.arrival_ti and ti == fn:substring(stock.arrival_ti,0,2)}">selected="selected"</c:if>>
			                                                   <c:if test="${ti < 10}">0</c:if><c:out value="${ti}"/>
			                                               </option>
			                                           </c:forEach>
			                                       </select>
			                                   </div>
			                                   <div class="pl5">
			                                       	시
			                                   </div>
			                                   <div class="pl5">
			                                       <select class="form-control width45px p2b" id="arrival_ti_2" name="arrival_ti_2">
			                                           <option value="00">00</option>
			                                           <c:forEach var="ti" varStatus="i" begin="1" end="59" step="1">
			                                               <option value="<c:if test="${ti < 10}">0</c:if><c:out value="${ti}" />"
			                                                       <c:if test="${not empty stock.arrival_ti and ti == fn:substring(stock.arrival_ti,2,4)}">selected="selected"</c:if>>
			                                                   <c:if test="${ti < 10}">0</c:if><c:out value="${ti}"/>
			                                               </option>
			                                           </c:forEach>
			                                       </select>
			                                   </div>
			                                   <div class="pl5">
			                                       	분
			                                   </div>
			                               </div>
			                            </td>
			                        </tr>
									<tr>
										<th class="text-right p2s">도착지</th>
										<td colspan="3">
											<%-- <input type="text" class="form-control p2b" id="arrival_area_name" name="arrival_area_name" alt="도착지" value="${stock.arrival_area_name}"> --%>
											<div class="form-row inline-pd">
		                                        <div class="col-1 pdr0">
		                                            <input type="text" class="form-control mw45" readonly="readonly"
		                                                   id="arrival_post_no" name="arrival_post_no"
		                                                   value="${stock.arrival_post_no}">
		                                        </div>
		                                        <div class="col-auto pdl5">
		                                            <button type="button" class="btn btn-primary-gra" style="margin-left: 5px"
		                                                    onclick="javascript:openSearchAddrPanel('fnSetStockArrival');">주소찾기
		                                            </button>
		                                        </div>
		                                        <div class="col-5">
		                                            <input type="text" class="form-control" readonly="readonly"
		                                                   id="arrival_addr1" name="arrival_addr1"
		                                                   value="${stock.arrival_addr1}">
		                                        </div>
		                                        <div class="col-4">
		                                            <input type="text" class="form-control" id="arrival_addr2" maxlength="75"
		                                                   name="arrival_addr2" value="${stock.arrival_addr2}">
		                                        </div>
		                                    </div>
										</td>
									</tr>
									<tr>
										<th class="text-right p2s">운송사</th>
										<td>
											<select class="form-control p2b" id="transport_cmp_cd" name="transport_cmp_cd" alt="운송사">
												<option value="">- 선택 -</option>
			                                    <c:forEach var="item" items="${codeMap['TRANSPORT_CMP']}">
			                                        <option value="${item.code_value}"
			                                        	<c:if test="${stock.transport_cmp_cd == item.code_value}">selected="selected"</c:if>>${item.code_name}
			                                        </option>
			                                    </c:forEach>
											</select>
										</td>
										<th class="text-right p2s">연락처</th>
										<td>
											<input type="text" class="form-control p2b" id="transport_tel_no" name="transport_tel_no" alt="연락처" value="${stock.transport_tel_no}" format="tel">
										</td>
									</tr>
									<tr>
										<th class="text-right p2s">운임</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" class="form-control text-right p2b" id="transport_amt" name="transport_amt" value="${stock.transport_amt}" alt="운임" format="decimal">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
										<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
										<%--<th class="text-right">대리점운임</th>--%>
										<th class="text-right">위탁판매점운임</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" class="form-control text-right" id="agency_transport_amt" name="agency_transport_amt" value="${stock.agency_transport_amt}" alt="위탁판매점운임" format="decimal">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">출하시특이사항</th>
										<td colspan="3">
											<textarea class="form-control" style="height: 50px;" id="out_remark" name="out_remark">${stock.out_remark}</textarea>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
<!-- /출하사항 -->
						<div class="title-wrap mt10">
							<h4>특이사항</h4>
							<div>
								<button type="button" id="_fnAdd" class="btn btn-default" onclick="javascript:fnAdd();"><i class="material-iconsadd text-default"></i>행추가</button>
							</div>
						</div>
						<div id="auiGrid_memo" style="margin-top: 5px; width: 100%; height: 200px"></div>
<!-- 결재자의견-->
						<c:if test="${apprMemoList != null && apprMemoList.size() != 0}">
							<div id="apprMemoList">
								<div class="title-wrap mt10">
									<h4>결재자의견</h4>
								</div>
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
						</c:if>
<!-- /결재자의견-->
					</div>
<!-- 우측 폼테이블-->
				</div>
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="right">
						<c:if test="${stock.machine_doc_status_cd eq '5' or stock.machine_doc_status_cd eq '6'}">
							<button type="button" class="btn btn-info" onclick="javascript:goChangeOutInfo();">출하사항변경</button>
							<button type="button" class="btn btn-info" onclick="javascript:goCheckSaleDoc();">품의서작성</button>
						</c:if>
						<c:if test="${empty stock.sale_machine_doc_no}">
							<button type="button" class="btn btn-info" onclick="javascript:goOut();" id="btnOut">출하처리</button>
						</c:if>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
							<jsp:param name="pos" value="BOM_R"/>
							<jsp:param name="mem_no" value="${doc_mem_no }"/>
							<jsp:param name="appr_yn" value="Y"/>
						</jsp:include>
					</div>
				</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
