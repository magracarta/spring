<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 장비입고관리-통관 > 장비통관등록 > null
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<%-- <c:set var="orderInfo" value="${result.orderInfo}"/> --%>
<%-- <c:set var="lcDtlList" value="${result.lcDtlList}"/> --%>
<%-- <c:set var="bodyNoList" value="${result.bodyNoList}"/> --%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var moneyUnitJson = JSON.parse('${codeMapJsonObj["MONEY_UNIT"]}');

		var jsonList = ${jsonList}  // lc 데이터
		var setData;
		var passInfo;

		var fileChangeYn = 'N';

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridTop();
			createAUIGridBottom();
			fnInit();

			<c:forEach var="list" items="${fileList}">fnPrintFile('${list.file_seq}', '${list.file_name}');</c:forEach>
			<c:forEach var="sendFileList" items="${sendFileList}">fnPrintSendFile('${sendFileList.send_file_seq}', '${sendFileList.send_file_name}');</c:forEach>
		});

		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 5;

		// 파일추가
		function fnAddFile(){
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}

			var fileSeqArr = [];
			var fileSeqStr = "";
			$("[name=file_seq]").each(function() {
				fileSeqArr.push($(this).val());
			});

			fileSeqStr = $M.getArrStr(fileSeqArr);

			var fileParam = "";
			if("" != fileSeqStr) {
				fileParam = '&file_seq_str='+fileSeqStr;
			}

			openFileUploadMultiPanel('setFileInfo', 'upload_type=LC&file_type=both&total_max_count=5'+fileParam);
		}

		// 첨부파일 출력 (멀티)
		function fnPrintFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item att_file_' + fileIndex + ' fileDiv"style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.att_file_div').append(str);
			fileIndex++;
		}

		// 파일세팅
		function setFileInfo(result) {
			$(".fileDiv").remove(); // 파일영역 초기화

			var fileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			for (var i = 0; i < fileList.length; i++) {
				// fileChangeYn = 'Y';
				fnPrintFile(fileList[i].file_seq, fileList[i].file_name);
			}
		}

		// 첨부서류 일괄다운로드
		function fnFileAllDownload() {
			var fileSeqArr = [];
			$("[name=file_seq]").each(function () {
				fileSeqArr.push($(this).val());
			});

			var paramObj = {
				'file_seq_str' : $M.getArrStr(fileSeqArr)
			}

			fileDownloadZip(paramObj);
		}

		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				// fileChangeYn = 'Y';
				$(".att_file_" + fileIndex).remove();
			} else {
				return false;
			}
		}

		// 송금증빙 첨부파일 index 변수
		var sendFileIndex = 1;
		// 송금증빙 첨수할 수 있는 파일의 개수
		var sendFileCount = 5;

		// 송금증빙 파일추가
		function goAddFileForSendPopup() {
			if($("input[name='att_send_file_seq']").size() >= sendFileCount) {
				alert("파일은 " + sendFileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}

			var sendFileSeqArr = [];
			var sendFileSeqStr = "";
			$("[name=att_send_file_seq]").each(function() {
				sendFileSeqArr.push($(this).val());
			});

			sendFileSeqStr = $M.getArrStr(sendFileSeqArr);

			var sendFileParam = "";
			if("" != sendFileSeqStr) {
				sendFileParam = '&file_seq_str='+sendFileSeqStr;
			}

			openFileUploadMultiPanel('setSendFileInfo', 'upload_type=LC&file_type=both&total_max_count=5'+sendFileParam);
		}

		// 송금증빙 파일세팅
		function setSendFileInfo(result) {
			$(".attSendFileDiv").remove(); // 파일영역 초기화

			var sendFileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			for (var i = 0; i < sendFileList.length; i++) {
				fileChangeYn = 'Y';
				fnPrintSendFile(sendFileList[i].file_seq, sendFileList[i].file_name);
			}
		}

		// 송금증빙 첨부파일 출력 (멀티)
		function fnPrintSendFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item att_send_file_' + sendFileIndex + ' attSendFileDiv"style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="att_send_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveSendFile(' + sendFileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.att_send_file_div').append(str);
			sendFileIndex++;
		}

		// 송금증빙 첨부파일 삭제
		function fnRemoveSendFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				fileChangeYn = 'Y';
				$(".att_send_file_" + fileIndex).remove();
			} else {
				return false;
			}
		}

		// 송금증빙 일괄다운로드
		function fnSendFileAllDownload() {
			var sendFileSeqArr = [];
			$("[name=att_send_file_seq]").each(function () {
				sendFileSeqArr.push($(this).val());
			});

			var paramObj = {
				'file_seq_str' : $M.getArrStr(sendFileSeqArr)
			}

			fileDownloadZip(paramObj);
		}

		function fnInit() {
			var remitProcData  = jsonList[0].remit_proc_date;

			console.log("remitProcData : ", remitProcData);
			if (remitProcData != "") {
				$M.setValue("lc_remit_plan_dt", remitProcData);
				$M.setValue("remit_proc_date", remitProcData);
				$("#lc_remit_plan_dt").attr("disabled", true);
				$("#lc_apply_er_price").attr("disabled", true);
				
				$("#_goRemitProcess").css("display", "none");
			} else {
				$("#_fnCancel").css("display", "none");
			}
			
		}
		
		function fnBtnControl() {
			console.log($M.getValue("remit_proc_date"));
			
			if ($M.getValue("remit_proc_date") == "") {
				$("#_goRemitProcess").css("display", "");
				$("#_fnCancel").css("display", "none");
				$("#lc_remit_plan_dt").attr("disabled", false);
				$("#lc_apply_er_price").attr("disabled", false);
			} else {
				$("#_goRemitProcess").css("display", "none");
				$("#_fnCancel").css("display", "");
				$("#lc_remit_plan_dt").attr("disabled", true);
				$("#lc_apply_er_price").attr("disabled", true);
			}
		}
		
		//발주내역
		function createAUIGridTop() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				enableMovingColumn : false
			};
			var columnLayout = [
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{
					headerText : "Part NO.", 
					dataField : "machine_name", 
					width : "15%",
					style : "aui-center"
				},
				{ 
					headerText : "Q'ty", 
					dataField : "qty", 
					dataType : "numeric",
					width : "5%", 
					style : "aui-center",
				},
				{ 
					headerText : "U/Price", 
					dataField : "unit_price", 
					dataType : "numeric",
					formatString : "#,##0.00",
					width : "11%", 
					style : "aui-right",
				},
				{ 
					headerText : "Amount", 
					dataField : "ship_total_amt", 
					dataType : "numeric",
					formatString : "#,##0.00",
					width : "11%", 
					style : "aui-right",
				},
				{ 
					headerText : "Option", 
					dataField : "opt_part_name", 
					width : "30%", 
					style : "aui-left",
				},
				{ 
					headerText : "선적수", 
					dataField : "machine_qty", 
					width : "5%",
					style : "aui-center"
				},
				{ 
					headerText : "등록시간", 
					dataField : "reg_date", 
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					style : "aui-center",
				}
			];
			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridTop, ${jsonList});
			$("#auiGridTop").resize();
		}
		
		//차대번호등록내역
		function createAUIGridBottom() {
			var gridPros = {
				rowIdField : "machine_seq",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
// 				showFooter : true,  // 2020.12.29 푸터의 부대비용 합계 삭제 
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : false,
				enableMovingColumn : false
			};
			var columnLayout = [
				{ 
					dataField : "machine_seq", 
					visible : false
				},
				{ 
					dataField : "maker_cd", 
					visible : false
				},
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "container_seq", 
					visible : false
				},
				{ 
					dataField : "in_yn", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{ 
					dataField : "machine_ship_no", 
					visible : false
				},
				{ 
					dataField : "machine_lc_no", 
					visible : false
				},
				{ 
					dataField : "pass_proc_date",
					visible : false
				},
				{ 
					dataField : "pass_yn",
					visible : false
				},
				{ 
					dataField : "pass_report_no",
					visible : false
				},
				{ 
					dataField : "pass_mng_no",
					visible : false
				},
				{ 
					dataField : "load_cost_amt",
					visible : false
				},
				{ 
					dataField : "mng_cost",
					visible : false
				},
				{ 
					dataField : "machine_ship_mng_cost_cd",
					visible : false
				},
				{ 
					dataField : "machine_ship_mng_cost_amt",
					visible : false
				},
				{
					dataField : "made_year",
					visible : false
				},
				{
					headerText : "Part NO.", 
					dataField : "machine_name", 
					width : "10%",
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "10%",
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "컨테이너명", 
					dataField : "container_name", 
					width : "10%",
					style : "aui-center"
				},
				{ 
					headerText : "화폐", 
					dataField : "money_unit_cd", 
					width : "5%",
					style : "aui-center",
				},
				{ 
					headerText : "외화단가", 
					dataField : "fe_unit_price", 
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0.00",
					rounding : "floor",
					style : "aui-right",
				},
				{ 
					headerText : "환율", 
					dataField : "apply_er_price", 
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0.0000",
// 					rounding : "floor",
					style : "aui-right",
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var desc_text = $M.decimalFormat(value);
// 						if(item["apply_er_price"] == "0") {
// 							desc_text = ""
// 						}
// 						return desc_text;
// 					}
				},
				{ 
					headerText : "산출원가", 
					dataField : "import_cost_amt", 
					dataType : "numeric",
					width : "10%",
					formatString : "#,##",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var desc_text = $M.decimalFormat(value);
						if(item["import_cost_amt"] == "0") {
							desc_text = ""
						}
						return desc_text;
					}
				},
				{ 
					headerText : "부대비용", 
					dataField : "ship_mng_cost_amt", 
					dataType : "numeric",
					width : "10%",
					formatString : "#,##0",
					style : "aui-right",
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var desc_text = $M.decimalFormat(value);
// 						if(item["ship_mng_cost_amt"] == "0") {
// 							desc_text = ""
// 						}
// 						return desc_text;
// 					}
				},
				{ 
					headerText : "관리원가", 
					dataField : "mng_cost_amt",
					dataType : "numeric",
					width : "10%",
					formatString : "#,##0",
					style : "aui-right",
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						var desc_text = $M.decimalFormat(value);
// 						if(item["mng_cost_amt"] == "0") {
// 							desc_text = ""
// 						}
// 						return desc_text;
// 					}
				},
				{ 
					headerText : "입고일자", 
					dataField : "in_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-cetner"
				},
				{ 
					headerText : "통관일자", 
					dataField : "pass_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-cetner"
				},
				{
					headerText : "통관상태",
					dataField : "pass_status_name",
					style : "aui-cetner"
				},
			];
			// 푸터레이아웃
// 			var footerColumnLayout = [ 
// 				{
// 					labelText : "합계",
// 					positionField : "import_cost_amt",
// 					style : "aui-right aui-footer",
// 				}, 
// 				{
// 					dataField : "ship_mng_cost_amt",
// 					positionField : "ship_mng_cost_amt",
// 					operation : "SUM",
// 					formatString : "#,##0",
// 					style : "aui-right aui-footer",
// 				}
// 			];
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setGridData(auiGridBottom, ${machineBodyList});
// 			AUIGrid.setFooter(auiGridBottom, footerColumnLayout);
			$("#auiGridBottom").resize();
			// 통관처리 팝업
			AUIGrid.bind(auiGridBottom, "cellClick", function(event) {
				if(event.dataField == "body_no" ) {
					console.log("event : ", event);
					if (event.item.pass_yn == "Y") {
						alert("통관(종결)처리 된 장비입니다.");
						return;
					}
					// 입고처리 된 row만 통관처리 가능.
					if (event.item.in_yn == "Y") {
						setData = {
							"machine_seq" : event.item.machine_seq,
						}
						
						passInfo = {
							"pass_dt" : event.item.pass_dt,
							"machine_seq" : event.item.machine_seq,
							"pass_mng_no" : event.item.pass_mng_no,
							"apply_er_price" : event.item.apply_er_price,
							"pass_report_no" : event.item.pass_report_no,
							"pass_proc_date" : event.item.pass_proc_date,
							"load_cost_amt" : event.item.load_cost_amt,
							"pass_yn" : event.item.pass_yn,
							"maker_cd" : event.item.maker_cd,
							"money_unit_cd" : event.item.money_unit_cd,
							"mng_cost" : event.item.mng_cost
						}

// 						var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=550, height=460, left=0, top=0";
						var popupOption = "";
						$M.goNextPage('/acnt/acnt0401p01', $M.toGetParam(setData), {popupStatus : popupOption});
					} else {
						alert("입고 처리 후 진행해 주세요.");
						return false;
					}
				}
			});	
			
			AUIGrid.bind(auiGridBottom, "rowCheckClick", function( event ) {
// 				if(event.item.pass_yn == "Y"){
// 					alert("이미 통관(종결)처리가 완료된 내역입니다.");
// 					AUIGrid.addUncheckedRowsByValue(auiGridBottom, "container_seq", event.item.container_seq);
// 					return;
// 				}
				
				if(event.item.in_yn == "N") {
					alert("장비입고를 먼저 진행 해 주세요.");
					AUIGrid.addUncheckedRowsByValue(auiGridBottom, "container_seq", event.item.container_seq);
					return;
				}
				
				if(event.item.container_seq != ""){
					if(event.checked){
						AUIGrid.addCheckedRowsByValue(auiGridBottom, "container_seq", event.item.container_seq);
					}else{
						AUIGrid.addUncheckedRowsByValue(auiGridBottom, "container_seq", event.item.container_seq);

					} 
						
				}
			});
			
		    // 구해진 칼럼 사이즈를 적용 시킴.
			var colSizeList = AUIGrid.getFitColumnSizeList(auiGridBottom, true);
		    AUIGrid.setColumnSizeList(auiGridBottom, colSizeList);
		}
		
		// 통관처리 팝업에서 받아온 데이터 그리드에 세팅
		function fnSetData(data) {
			console.log("팝업창에서 받은 데이터 : ", data);
			data.aui_status_cd = 'R';
			var rowIdField = AUIGrid.getProp(auiGridBottom, "rowIdField");
			var rowIndex = AUIGrid.rowIdToIndex(auiGridBottom, data[rowIdField]);
			AUIGrid.updateRow(auiGridBottom, data, rowIndex);
		}
		
		// 목록
	    function fnList() {
	    	history.back();
	    }
    
	    // 송금완료
	    function goRemitProcess() {
	    	if ($M.getValue("lc_remit_plan_dt") == "") {
	    		alert("송금일자를 선택해주세요.");
	    		return;
	    	}
	    	
			if (confirm("송금완료 처리 하시겠습니까 ?") == false) {
				return false;
			}
			
	    	var remitPlanDt = $M.getValue("lc_remit_plan_dt");
	    	$M.setValue("remit_proc_date", remitPlanDt);
	    	alert("송금완료 최종처리는 저장 시 반영됩니다.");
	    	fnBtnControl();
	    	
	    	console.log("remit_proc_date : ", $M.getValue("remit_proc_date"));
	    }
	    
	    // 송금취소
	    function fnCancel() {
			if (confirm("송금취소 처리 하시겠습니까 ?") == false) {
				return false;
			}
			
			$M.setValue("remit_proc_date", "");
			$M.setValue("lc_remit_plan_dt", ${list[0].remit_plan_dt}+"");
			alert("송금취소 최종처리는 저장 시 반영됩니다.");
			fnBtnControl();
	    }
	    
	    // 선임료조회
	    function goShipLoadCostPopup() {
	    	var changeGridData = AUIGrid.getEditedRowItems(auiGridBottom); // 변경내역
	    	if (changeGridData.length != 0) {
    			alert("변경내역을 저장 후에 진행 해 주세요.");
    			return;
	    	}
	    	
	    	var params = {};
			var popupOption = "";
			$M.goNextPage('/acnt/acnt0401p02', '', {popupStatus : popupOption});
	    }

	    // 부대비용관리
	    function goShipMngCostPopup() {
	    	var changeGridData = AUIGrid.getEditedRowItems(auiGridBottom); // 변경내역
	    	if (changeGridData.length != 0) {
    			alert("변경내역을 저장 후에 진행 해 주세요.");
    			return;
	    	}
	    	
	    	var params = {
	    			machine_lc_no : $M.getValue("machine_lc_no")
	    	}

	    	var popupOption = "";
			$M.goNextPage('/acnt/acnt0401p03', $M.toGetParam(params), {popupStatus : popupOption});
	    }

	    // 산출원가 및 부대비용 배분
	    function fnCalculateAmount() {
	    	var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridBottom);
	    	
// 	    	if (checkedItems.length == 0) {
// 	    		alert("체크된 차대번호가 없습니다.");
// 	    		return;
// 	    	}
	    	
// 			for (var i = 0; i < checkedItems.length; i++) {
// 				if (checkedItems[i].pass_dt == "") {
// 					alert("차대번호를 클릭하여 통관처리를 먼저 해주세요.");
// 					return;
// 				}
// 			}
	    	
	    	var changeGridData = AUIGrid.getEditedRowItems(auiGridBottom); // 변경내역
// 	    	if (changeGridData.length != 0) {
//     			alert("변경내역을 저장 후에 진행 해 주세요.");
//     			return;
// 	    	}
	    	
	    	// 통관일자 있는것만 추출
	    	var targetGridData = [];
	    	var gridData = AUIGrid.getGridData(auiGridBottom);
	    	
	    	console.log("gridData : ", gridData);
	    	
	    	for(var i = 0; i < gridData.length; i++) {
	    		var passDt = gridData[i].pass_dt;
	    		if(passDt != "" && passDt != null) {
	    			targetGridData.push(gridData[i]);	
	    		}
	    	}
	    	
	    	console.log("targetGridData : ", targetGridData);
	    	
	    	if(targetGridData.length == 0) {
	    		alert("차대번호를 클릭하여 통관처리를 먼저 해주세요.");
	    		return;
	    	}
	    	
	    	/* 
	     	(외화단가 계) : 통관일자가 있는 행의 외화단가 합
	     	산출원가 = 외화단가 * 기준환율
	     	부대비용 = 전체부대비용 / 외화단가계 * 외화단가
	     	관리원가 = 산출원가 + 부대비용 
	     	*/
	     	
	    	// 외화단가 계
	    	var sum = 0;
	     	for(var i in targetGridData) {
	     		sum += targetGridData[i].fe_unit_price;
	     	}
	     	
	     	console.log("sum : ", sum);
	     	console.log("부대비용 합계 : ", $M.toNum($M.getValue("sum_amt")));
	     	
	     	
	     	// import_cost_amt : 산출원가
	     	// ship_mng_cost_amt : 부대비용
	     	// mng_cost_amt : 관리원가
	     	
	     	for(var i in targetGridData) {
	     		// 산출원가
	     		targetGridData[i].import_cost_amt = Math.floor($M.toNum(targetGridData[i].fe_unit_price) * $M.toNum(targetGridData[i].apply_er_price) + 0.5);
// 	     		targetGridData[i].import_cost_amt = Math.floor($M.toNum(targetGridData[i].fe_unit_price) * $M.toNum(targetGridData[i].apply_er_price));
	     		// 부대비용
// 	     		targetGridData[i].ship_mng_cost_amt = Math.floor($M.toNum($M.getValue("sum_amt")) / $M.toNum(sum) * $M.toNum(targetGridData[i].fe_unit_price));
	     		targetGridData[i].ship_mng_cost_amt = $M.toNum($M.getValue("sum_amt")) / sum * $M.toNum(targetGridData[i].fe_unit_price);
	     		// 관리원가
// 	     		targetGridData[i].mng_cost_amt = Math.floor($M.toNum(targetGridData[i].import_cost_amt) + $M.toNum(targetGridData[i].ship_mng_cost_amt));
	     		targetGridData[i].mng_cost_amt = $M.toNum(targetGridData[i].import_cost_amt) + $M.toNum(targetGridData[i].ship_mng_cost_amt);
	     		
// 				console.log(targetGridData[i].mng_cost_amt);
	     		AUIGrid.updateRowsById(auiGridBottom, targetGridData[i], true);
	     	}
	     	
	    }

	    // 통관(종결)처리
	    function goPassEnd() {
	    	var changeGridData = AUIGrid.getEditedRowItems(auiGridBottom); // 변경내역
	    	var gridData = AUIGrid.getGridData(auiGridBottom);
	    	
	    	// 체크한 row 정보
	    	var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridBottom);
	    	console.log("checkedItems : ", checkedItems);
	    	console.log("gridData : ", gridData);
	    	
			if(checkedItems.length == 0) {
				alert("통관(종결)처리할 내역을 선택해주세요.");
				return;
			}
			
			for (var i = 0; i < checkedItems.length; i++) {
				if (checkedItems[i].pass_dt == "") {
					alert("차대번호를 클릭하여 통관처리를 먼저 해주세요.");
					return;
				}

				if (checkedItems[i].import_cost_amt == 0 || checkedItems[i].mng_cost_amt == 0) {
					alert("통관처리, 산출원가 및 부대비용 배분을 해주세요.");
					return;
				}
				
				if (checkedItems[i].pass_yn == "Y") {
					alert("이미 통관(종결)처리 된 내역이 있습니다.");
					return;
				}
			}
			
			if (confirm("저장 후 통관(종결)처리 하시겠습니까?") == false) {
				return false;
			}
			
			goSave("PASSEND");
	    }
	    
	    function goPassProcess() {
	    	var machine_seq_arr = [];
			var container_seq_arr = [];
			var pass_yn_arr = [];
			var pass_mem_no_arr = [];
			var import_cost_amt_arr = [];
			var ship_mng_cost_amt_arr = [];
			var mng_cost_amt_arr = [];
			var container_status_cd_arr = [];
			var apply_er_price_arr = [];
			var fe_unit_price_arr = [];
			
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridBottom);
			
			for (var i = 0; i < checkedItems.length; i++) {
				machine_seq_arr.push(checkedItems[i].machine_seq);
				container_seq_arr.push(checkedItems[i].container_seq);
				pass_yn_arr.push("Y");
				pass_mem_no_arr.push("${SecureUser.mem_no}");
				import_cost_amt_arr.push(checkedItems[i].import_cost_amt);
				ship_mng_cost_amt_arr.push(checkedItems[i].ship_mng_cost_amt);
				mng_cost_amt_arr.push(checkedItems[i].mng_cost_amt);
				apply_er_price_arr.push(checkedItems[i].apply_er_price);
				fe_unit_price_arr.push(checkedItems[i].fe_unit_price);
				container_status_cd_arr.push("03");
			}
			
			var option = {
					isEmpty : true
			};
			
			var cnt = 0;
			var pass_ypn = "Y";
			var machine_lc_status_cd = "22"
			
			var gridData = AUIGrid.getGridData(auiGridBottom);
			
			for (var i = 0; i < gridData.length; i++) {
				if (gridData[i].pass_dt == "") {
					cnt++;					
				}
			}
			
			if (cnt != 0) {
				pass_ypn = "P";
				machine_lc_status_cd = "21"
			}
			
 			var param = {
 					machine_lc_no : $M.getValue("machine_lc_no"),
 					machine_seq_str : $M.getArrStr(machine_seq_arr, option),
 					container_seq_str : $M.getArrStr(container_seq_arr, option),
 					pass_yn_str : $M.getArrStr(pass_yn_arr, option),
 					pass_mem_no_str : $M.getArrStr(pass_mem_no_arr, option),
 					import_cost_amt_str : $M.getArrStr(import_cost_amt_arr, option), 
 					ship_mng_cost_amt_str : $M.getArrStr(ship_mng_cost_amt_arr, option), 
 					mng_cost_amt_str : $M.getArrStr(mng_cost_amt_arr, option), 
 					container_status_cd_str : $M.getArrStr(container_status_cd_arr, option), 
 					apply_er_price_str : $M.getArrStr(apply_er_price_arr, option), 
 					fe_unit_price_str : $M.getArrStr(fe_unit_price_arr, option), 
 					pass_ypn : pass_ypn,
 					machine_lc_status_cd : machine_lc_status_cd
			}
			
			console.log("param : ", param);
 			
			$M.goNextPageAjax(this_page + "/pass", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("통관(종결)처리가 완료되었습니다.");
		    			location.reload();
		    			try {
			    			opener.goSearch();
		    			} catch(e) {
									    				
		    			}
// 		    			opener.goSearch();
					}
				}
			);	
	    }


		// 통관(해지)처리
		function goPassEndCancel() {
			// 체크한 row 정보
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridBottom);

			if(checkedItems.length == 0) {
				alert("통관(해지)처리할 내역을 선택해주세요.");
				return;
			}

			for (var i = 0; i < checkedItems.length; i++) {
				if (checkedItems[i].pass_yn == "N") {
					alert("컨테이너명(" + checkedItems[i].container_name + ")은 통관(종결)처리 된 내역이 아닙니다.");
					return;
				}
			}

			if (confirm("통관 해지 처리를 하시겠습니까?") == false) {
				return;
			}

			var param = {
				machine_lc_no : $M.getValue("machine_lc_no"),
				container_seq_str : $M.getArrStr(checkedItems, {key : 'container_seq'}),
				machine_seq_str : $M.getArrStr(checkedItems, {key : 'machine_seq'}),
			}

			$M.goNextPageAjax(this_page + "/cancelPass", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("통관(해지)처리가 완료되었습니다.");
						location.reload();
						try {
							opener.goSearch();
						} catch(e) {}
					}
				});
		}
	    
	    // 저장
	    function goSave(val) {
	    	console.log("val : ", val);
	    	
			var frm = document.main_form;
			
			// 2022-11-01 (SR:14479) 송금증빙, 첨부서류 기능 추가
			var idx = 1;
			$("input[name='file_seq']").each(function() {
				var str = 'att_file_seq_' + idx;
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				idx++;
			});
			for(; idx <= fileCount; idx++) {
				$M.setValue('att_file_seq_' + idx, 0);
			}

			var sendIdx = 1;
			$("input[name='att_send_file_seq']").each(function() {
				var str = 'send_file_seq_' + sendIdx;
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				sendIdx++;
			});
			for(; sendIdx <= sendFileCount; sendIdx++) {
				$M.setValue('send_file_seq_' + sendIdx, 0);
			}

			$M.setValue("file_change_yn", fileChangeYn);
			
			frm = $M.toValueForm(frm);
	    	
	    	var changeGridData = AUIGrid.getEditedRowItems(auiGridBottom); // 변경내역
	    	console.log("changeGridData : ", changeGridData);
			
	    	// 입력 form 정보
// 	    	var machine_lc_no = [];  // LC 번호
// 	    	var seq_no = [];		 // LC 순번
// 	    	var remit_proc_date = []; // 송급처리일시
// 	    	var pass_remark = [];    // 통관비고
	    	
	    	// 차대번호등록내역 그리드 정보
	    	// 장비통관 table 정보
	    	var machine_seq = [];    // 장비대장번호
	    	var container_seq = [];  // 컨테이너 번호
	    	var pass_yn = [];		 // 통관 여부
	    	var pass_dt = [];		 // 통관 일자 
	    	var pass_proc_date = []; // 통관 처리 일시
	    	var pass_mng_no = [];    // 관리번호
	    	var pass_report_no = []; // 신고번호
	    	var money_unit_cd = [];  // 화페단위
	    	var apply_er_price = []; // 적용환율
	    	var fe_unit_price = [];     // 외화단가
	    	var import_cost_amt = []; // 산출원가
	    	var ship_mng_cost_amt = []; // 부대비용
	    	var mng_cost_amt = [];    // 관리원가
	    	var origin_machine_seq = [];
			var made_year = [];
	    	
	    	// 선임료관리 table 정보
	    	var machine_ship_load_cost_seq = []; // 선임료번호
	    	var maker_cd = [];  // 메이커코드
	    	var load_cost_amt = []; // 금액
	    	
	    	// 장비부대비용관리 table 정보
	    	var machine_seq = [];  // 장비대장번호
	    	var machine_ship_mng_cost_cd = []; // 장비선적부대비용코드
	    	var mng_cost_amt = [];  // 금액
	    	var mng_cost = [];
	    	var codeList = [];
	    	var amtList = [];
	    	var mngList = [];
	    	
	    	var machine_ship_mng_cost_cd_arr;
	    	for (var i = 0; i < changeGridData.length; i++) {
// 	    		machine_lc_no.push(changeGridData[i].machine_lc_no);
// 	    		seq_no.push(changeGridData[i].seq_no);
// 	    		remit_proc_date.push(changeGridData[i].remit_proc_date);
// 	    		pass_remark.push(changeGridData[i].pass_remark);
	    		
	    		machine_seq.push(changeGridData[i].machine_seq);
	    		origin_machine_seq.push(changeGridData[i].machine_seq);
	    		container_seq.push(changeGridData[i].container_seq);
	    		pass_yn.push(changeGridData[i].pass_yn);
	    		pass_dt.push(changeGridData[i].pass_dt);
	    		pass_proc_date.push(changeGridData[i].pass_proc_date);
	    		pass_mng_no.push(changeGridData[i].pass_mng_no);
	    		pass_report_no.push(changeGridData[i].pass_report_no);
	    		money_unit_cd.push(changeGridData[i].money_unit_cd);
	    		apply_er_price.push(changeGridData[i].apply_er_price);
	    		fe_unit_price.push(changeGridData[i].fe_unit_price);
	    		import_cost_amt.push(changeGridData[i].import_cost_amt);
	    		ship_mng_cost_amt.push(changeGridData[i].ship_mng_cost_amt);
	    		mng_cost_amt.push(changeGridData[i].mng_cost_amt);
	    		made_year.push(changeGridData[i].pass_dt != ""? changeGridData[i].pass_dt.substring(0, 4) : "");

	    		machine_ship_load_cost_seq.push(changeGridData[i].machine_ship_load_cost_seq);
	    		maker_cd.push(changeGridData[i].maker_cd);
	    		load_cost_amt.push(changeGridData[i].load_cost_amt);
	    		codeList.push(changeGridData[i].machine_ship_mng_cost_cd);
	    		amtList.push(changeGridData[i].machine_ship_mng_cost_amt);
	    		mngList.push(changeGridData[i].mng_cost);
	    	}
	    	
	    	var seq = [];
	    	var cost_cd = [];
	    	var amt = [];
	    	
	    	console.log("mngList : ", mngList);
	    	for (var i = 0; i < mngList.length; i++) {
	    		if (mngList[i] != undefined) {
		    		for (var j = 0; j < mngList[i].length; j++) {
		    			seq.push(mngList[i][j].machine_seq);
		    			cost_cd.push(mngList[i][j].machine_ship_mng_cost_cd);
		    			amt.push(parseFloat(mngList[i][j].amt));
		    		}
	    		}
	    	}

	    	var option = {
					isEmpty : true
			};
	    	
			$M.setValue(frm, "mng_machine_seq_str", $M.getArrStr(machine_seq, option));
			$M.setValue(frm, "container_seq_str", $M.getArrStr(container_seq, option));
			$M.setValue(frm, "pass_yn_str", $M.getArrStr(pass_yn, option));
			$M.setValue(frm, "pass_dt_str", $M.getArrStr(pass_dt, option));
			$M.setValue(frm, "pass_proc_date_str", $M.getArrStr(pass_proc_date, option));
			$M.setValue(frm, "pass_mng_no_str", $M.getArrStr(pass_mng_no, option));
			$M.setValue(frm, "pass_report_no_str", $M.getArrStr(pass_report_no, option));
			$M.setValue(frm, "money_unit_cd_str", $M.getArrStr(money_unit_cd, option));
			$M.setValue(frm, "apply_er_price_str", $M.getArrStr(apply_er_price, option));
			$M.setValue(frm, "fe_unit_price_str", $M.getArrStr(fe_unit_price, option));
			$M.setValue(frm, "import_cost_amt_str", $M.getArrStr(import_cost_amt, option));
			$M.setValue(frm, "ship_mng_cost_amt_str", $M.getArrStr(ship_mng_cost_amt, option));
			$M.setValue(frm, "mng_cost_amt_str", $M.getArrStr(mng_cost_amt, option));
			$M.setValue(frm, "machine_ship_load_cost_seq_str", $M.getArrStr(machine_ship_load_cost_seq, option));	    	
			$M.setValue(frm, "maker_cd_str", $M.getArrStr(maker_cd, option));	    	
			$M.setValue(frm, "load_cost_amt_str", $M.getArrStr(load_cost_amt, option));	    	
			$M.setValue(frm, "mng_cost_str", $M.getArrStr(mng_cost, option));	    	
			$M.setValue(frm, "machine_seq_str", $M.getArrStr(seq, option));	    	
			$M.setValue(frm, "origin_machine_seq_str", $M.getArrStr(origin_machine_seq, option));	    	
			$M.setValue(frm, "machine_ship_mng_cost_cd_str", $M.getArrStr(cost_cd, option));	    	
			$M.setValue(frm, "amt_str", $M.getArrStr(amt, option));	    	
			$M.setValue(frm, "made_year_str", $M.getArrStr(made_year, option));

			console.log("결과 ? -> ", frm);
	    	
			var msg = "저장하시겠습니까?";

			if (val == "PASSEND") {
				$M.goNextPageAjax(this_page + "/save", frm , {method : 'POST'},
					function(result) {
			    		if(result.success) {
							goPassProcess();
						}
					}
				);
			} else if (val == "CHILD") {
				$M.goNextPageAjax(this_page + "/save", frm , {method : 'POST'},
					function(result) {
			    		if(result.success) {
// 			    			alert("저장이 완료되었습니다.");
// 	 		    			location.reload();
						}
					}
				);
			} else {
				$M.goNextPageAjaxMsg(msg, this_page + "/save", frm , {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			alert("저장이 완료되었습니다.");
	 		    			location.reload();
			    			try {
				    			opener.goSearch();
			    			} catch(e) {
										    				
			    			}
// 	 		    			opener.goSearch();
						}
					}
				);
			}
	    }
	    
		//팝업 끄기
		function fnClose() {
			window.close(); 
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="totalMngCostAmt" name="totalMngCostAmt">
<input type="hidden" id="machine_lc_status_cd" name="machine_lc_status_cd">
<input type="hidden" id="pass_ypn" name="pass_ypn">
<input type="hidden" name="remit_proc_date">
<input type="hidden" name="remit_plan_dt" value="${list[0].remit_plan_dt}">
<input type="hidden" name="sum_amt" value="${map.sum_amt}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
        </div>
        
        <!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<div class="doc-info" style="flex: 1;">				
					<h4>장비통관등록</h4>		
				</div>		
			</div>
			
			<!-- 상단 폼테이블 -->	
					<div>
						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="140px">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">관리번호</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width120px">
<%-- 												<input type="hidden" name="machine_lc_no" value="${list[0].machine_lc_no}"> --%>
												<input type="text" class="form-control" readonly id="machine_lc_no" name="machine_lc_no" value="${list[0].machine_lc_no}">
											</div>
											/ 작성일자 : ${inputParam.reg_dt}
										</div>
									</td>
									<th class="text-right">담당자</th>
									<td>
										<input type="text" class="form-control width80px" id="reg_mem_name" name="reg_mem_name" value="${list[0].reg_mem_name}" readonly alt="담당자"  required="required">
										<input type="hidden" name="reg_id" id="reg_id" value="${list[0].reg.mem_no}" >
									</td>
									<th class="text-right">상태</th>
									<td colspan="3">
										${list[0].machine_lc_status_name}
									</td>
								</tr>
								<tr>
									<th class="text-right">To</th>
									<td>
										<input type="text" class="form-control width200px" id="cust_name" name="cust_name" readonly alt="To"  required="required" value="${list[0].cust_name}">
										<input type="hidden" id="client_cust_no" name="client_cust_no" value="${list[0].client_cust_no}">
									</td>
									<th rowspan="2" class="text-right">From</th>
									<td rowspan="2">
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" class="form-control width200px" id="mem_eng_name" name="mem_eng_name" alt="From"  required="required" value="${list[0].mem_eng_name}" readonly>
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control width200px" readonly id="job_eng_name" name="job_eng_name" value="${list[0].job_eng_name}">
											</div>
										</div>
									</td>
									<th rowspan="3" class="text-right">Remark</th>
									<td rowspan="3" colspan="3">
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_1" name="remark_1" alt="Remark"  required="required" value="${list[0].remark_1}">
											</div>
										</div>
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_2" name="remark_2" value="${list[0].remark_2}">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_3" name="remark_3" value="${list[0].remark_3}">
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">Attn</th>
									<td>
										<input type="text" class="form-control width200px" readonly id="client_charge_name" name="client_charge_name" alt="Attn"  required="required" value="${list[0].client_charge_name}">
									</td>
								</tr>
								<tr>
									<th class="text-right">CC</th>
									<td>
										<input type="text" class="form-control width200px" readonly id="client_rep_name" name="client_rep_name" alt="CC"  required="required" value="${list[0].client_rep_name}">
									</td>
									<th class="text-right">RE</th>
									<td>
										<input type="text" class="form-control width200px" readonly id="order_remark" name="order_remark" alt="RE"  required="required" value="${list[0].order_remark}">
									</td>
								</tr>
								<tr>
									<th class="text-right">생산완료월</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-3">
												<input type="text" class="form-control width200px" readonly id="order_year" name="order_year" value="${inputParam.order_year}년">
											</div>
											<div class="col-2">
												<input type="text" class="form-control width200px" readonly id="order_mon" name="order_mon" value="${inputParam.order_mon}월">
											</div>			
										</div>							
		<!-- 								<div class="input-group"> -->
		<%-- 									<input type="text" class="form-control rb border-right-0 width80px calDate" id="order_dt" name="order_dt" dateformat="yyyy-MM-dd" alt="발주일자" value="${list[0].order_dt}" alt="발주일자"  required="required"> --%>
		<!-- 								</div> -->
									</td>
									<th class="text-right">입고예정</th>
									<td>
										<input type="text" class="form-control width100px" alt="입고예정일" value="${list[0].in_plan_dt}" readonly id="in_plan_dt" name="in_plan_dt" dateformat="yyyy-MM-dd">
<%-- 											<input type="text" class="form-control border-right-0" readonly value="${orderInfo.in_plan_dt}"> --%>
<!-- 											<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button> -->
									</td>
									<th class="text-right">송금일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col width120px">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="lc_remit_plan_dt" name="lc_remit_plan_dt"  dateformat="yyyy-MM-dd" value="${list[0].remit_plan_dt}">
<!-- 													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button> -->
												</div>										
											</div>
											<div class="col width80px">
<!-- 												<button type="button" class="btn btn-primary-gra" onclick="javascript:alert('송금완료');">송금완료</button> -->
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
											</div>
											
										</div>
									</td>	
									<th class="text-right">송금환율</th>
									<td>
										<div class="col width120px">
												<input type="text" class="form-control width120px" id="lc_apply_er_price" name="lc_apply_er_price" format="decimal4" required="required" value="${list[0].apply_er_price}">
										</div>
									</td>									
								</tr>
								<tr>
									<th class="text-right">합계금액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width120px">
												<input type="text" class="form-control text-right width140px" readonly name="total_amt" id="total_amt" format="decimal" alt="합계금액"  required="required" value="${list[0].total_amt}">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>		
									<th class="text-right">참고</th>
									<td colspan="5">
										<input type="text" class="form-control" name="pass_remark" value="${list[0].pass_remark}">
									</td>
								</tr>
								<tr>
									<th class="text-right">첨부서류</th>
									<td colspan="6" style="border-right: white;">
										<div class="table-attfile att_file_div" style="width:100%;">
											<div class="table-attfile" style="float:left">
												<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
											</div>
										</div>
									</td>
									<td style="border-left: white;">
										<div class="table-attfile" style="display: inline-block; margin: 0 5px;  float: right;">
											<button type="button" class="btn btn-primary-gra mr10"  onclick="javascript:fnFileAllDownload();">파일일괄다운로드</button>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">송금증빙</th>
									<td colspan="6" style="border-right: white;">
										<div class="table-attfile att_send_file_div" style="width:100%;">
											<div class="table-attfile" style="float:left">
												<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goAddFileForSendPopup();">파일찾기</button>
											</div>
										</div>
									</td>
									<td style="border-left: white;">
										<div class="table-attfile" style="display: inline-block; margin: 0 5px;  float: right;">
											<button type="button" class="btn btn-primary-gra mr10"  onclick="javascript:fnSendFileAllDownload();">파일일괄다운로드</button>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /상단 폼테이블 -->
<!-- 발주내역 -->
					<div>
						<div class="title-wrap mt10">
							<h4>발주내역</h4>
						</div>
						<div id="auiGridTop" style="margin-top: 5px; height: 150px;"></div>
					</div>
<!-- /발주내역 -->
<!-- 발주내역 -->
					<div>
						<div class="title-wrap mt10">
							<h4>차대번호등록내역</h4>
							<div class="right">
								<div class="form-row inline-pd widthfix" style="display: inline-block; margin-right: 10px;">
									부대비용 합계
									<div class="col width120px" style="display: inline-block;">
										<input type="text" class="form-control text-right width140px right" readonly name="mng_cost_sum_amt" id="mng_cost_sum_amt" format="decimal" datatype="int" alt="합계금액"  required="required" value="${map.sum_amt}">
									</div>
									<div class="col width16px" style="display: inline-block;">원</div>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
						<div id="auiGridBottom" style="margin-top: 5px; height: 330px;"></div>
					</div>
<!-- /발주내역 -->
<!-- /폼테이블 -->
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
	<input type="hidden" id="att_file_seq_1" name="att_file_seq_1" value="${list[0].att_file_seq_1 }"/>
	<input type="hidden" id="att_file_seq_2" name="att_file_seq_2" value="${list[0].att_file_seq_2 }"/>
	<input type="hidden" id="att_file_seq_3" name="att_file_seq_3" value="${list[0].att_file_seq_3 }"/>
	<input type="hidden" id="att_file_seq_4" name="att_file_seq_4" value="${list[0].att_file_seq_4 }"/>
	<input type="hidden" id="att_file_seq_5" name="att_file_seq_5" value="${list[0].att_file_seq_5 }"/>
	<input type="hidden" id="send_file_seq_1" name="send_file_seq_1" value="${list[0].send_file_seq_1 }"/>
	<input type="hidden" id="send_file_seq_2" name="send_file_seq_2" value="${list[0].send_file_seq_2 }"/>
	<input type="hidden" id="send_file_seq_3" name="send_file_seq_3" value="${list[0].send_file_seq_3 }"/>
	<input type="hidden" id="send_file_seq_4" name="send_file_seq_4" value="${list[0].send_file_seq_4 }"/>
	<input type="hidden" id="send_file_seq_5" name="send_file_seq_5" value="${list[0].send_file_seq_5 }"/>
</form>
</body>
</html>
