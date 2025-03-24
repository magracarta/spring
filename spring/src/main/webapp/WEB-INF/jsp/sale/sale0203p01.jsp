<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > null > LC Open 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var jsonList = ${jsonList};
		var memNo = '${SecureUser.mem_no}';
		var regMemNo = jsonList[0].reg_mem_no;
		var machineShipList = ${machineShipList};
		var lcStatus = jsonList[0].machine_lc_status_cd;
		var rightAuiGrid;
		
		var fileChangeYn = 'N';
	
		$(document).ready(function() {
			createLeftAuiGrid();
			createRightAuiGrid();
			
			if (lcStatus != 01 || regMemNo != memNo) {
				fnModifyControl();
			}
			<c:forEach var="list" items="${fileList}">fnPrintFile('${list.file_seq}', '${list.file_name}');</c:forEach>
			<c:forEach var="sendFileList" items="${sendFileList}">fnPrintSendFile('${sendFileList.send_file_seq}', '${sendFileList.send_file_name}');</c:forEach>

		});
		
		// 관리부 요청
		function goRequestPaper() {
			var machineLcNo = $M.getValue("machine_lc_no");
			$M.goNextPageAjaxMsg("관리부에게 쪽지를 전송하시겠습니까?", this_page + "/" + machineLcNo + "/paper", "" , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("쪽지 전송이 완료되었습니다.");
					}
				}
			);
		}
		
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
				fileChangeYn = 'Y';
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
				fileChangeYn = 'Y';
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
				// fileChangeYn = 'Y';
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
				// fileChangeYn = 'Y';
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
		
		// 결재상태에 따라 수정가능 제어
		function fnModifyControl() {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :button[onclick='javascript:fnAddCheck();']").prop("disabled", true);
			$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);

			$("#main_form :button[onclick='javascript:goAddFileForSendPopup();']").prop("disabled", false);
			$("#btnPaper").prop("disabled", false);

			$("#main_form :button[onclick='javascript:fnAddFile();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goModify();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnFileAllDownload();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnSendFileAllDownload();']").prop("disabled", false);

			<c:if test="${page.fnc.F00181_001 eq 'Y'}">
				$("#_goModify").addClass("dpn");
				$("#_fnClose").parent().prepend('<button type="button" id="_goModify" class="btn btn-info" onclick="javascript:goModify();">수정</button>');
			</c:if>

			// 자동화추가개발 ETD, ETA, 입고예정, 송금예정 disabled 해제
			$("#etd").prop("disabled", false);
			$("#eta").prop("disabled", false);
			$("#in_plan_dt").prop("disabled", false);
			$("#remit_plan_dt").prop("disabled", false);
			$("#ship_remark").prop("disabled", false);
			$(".ui-datepicker-trigger").prop("disabled", false);
		}
		
		//그리드생성
		function createLeftAuiGrid() {
			var gridPros = {
					rowIdField : "_$uid",
					showStateColumn : false,
					showRowNumColumn: false,
					showFooter : true,
					footerPosition : "top",
					editable : true,
					showStateColumn : true,
					//체크박스 출력 여부
					showRowCheckColumn : true,
					//전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
					softRemoveRowMode : false,
					headerHeight : 40
				};
			var columnLayout = [
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "opt_code", 
					visible : false
				},
				{ 
					dataField : "opt_name", 
					visible : false
				},
				{ 
					dataField : "ship_seq_no", 
					visible : false
				},
				{ 
					dataField : "flag", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{
					headerText : "선적발주일", 
					dataField : "ship_dt", 
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					width : "13%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "선적발주번호", 
					dataField : "machine_ship_no", 
					width : "12%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "발주처", 
					dataField : "cust_name", 
					width : "18%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "발주내역", 
					dataField : "machine_name", 
					width : "20%", 
					style : "aui-left",
					editable : false
				},
				{ 
					headerText : "선적발주<br>잔여수량", 
					dataField : "lc_poss_qty",
					dataType : "numeric",
					width : "8%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "수량", 
					dataField : "qty",
					dataType : "numeric",
					width : "8%", 
					style : "aui-center",
					editable : true,
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (regMemNo != memNo || lcStatus != 01) {
							return null;
						} else {
							return "aui-editable";
						}
					},
					editRenderer : {
					      type : "InputEditRenderer",
					      min : 1,
					      onlyNumeric : true,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "합계금액", 
					dataField : "ship_total_amt",
					dataType : "numeric",
					style : "aui-right",
					editable : false,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						// 수량 * 단가 계산
						return ( item.lc_poss_qty * item.unit_price ); 
					}
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_name"
				}, 
				{
					dataField : "lc_poss_qty",
					positionField : "lc_poss_qty",
					operation : "SUM",
					style : "aui-center aui-footer"
				},
				{
					dataField : "qty",
					positionField : "qty",
					operation : "SUM",
					style : "aui-center aui-footer"
				},
				{
					dataField : "ship_total_amt",
					positionField : "ship_total_amt",
					operation : "SUM",
					formatString : "#,##0.00",
					style : "aui-right aui-footer",
				}
			];
			
			leftAuiGrid = AUIGrid.create("#leftAuiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(leftAuiGrid, footerColumnLayout);
			AUIGrid.setGridData(leftAuiGrid, ${machineShipList});
			$("#leftAuiGrid").resize();
			AUIGrid.bind(leftAuiGrid, "cellEditBegin", function (event) {
				// 결재상태에 따라 에디팅 제어
				if (regMemNo != memNo || lcStatus != 01) {
					if (event.dataField == "qty") {
						return false;
					}
				}
				
			});
		}
		
		//그리드생성
		function createRightAuiGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				showRowNumColumn: false,
				showFooter : true,
				footerPosition : "top",
				editable : false,
// 				softRemoveRowMode : false,
			};
			var columnLayout = [
				{ 
					dataField : "flag", 
					visible : false
				},
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "ship_seq_no", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{
					headerText : "선적발주번호", 
					dataField : "machine_ship_no", 
					width : "12%", 
					style : "aui-center"
				},
				{ 
					headerText : "Part NO", 
					dataField : "machine_name", 
					width : "12%", 
					style : "aui-center"
				},
				{ 
					headerText : "Qty", 
					dataField : "qty", 
					width : "8%", 
					dataType : "numeric",
					style : "aui-center",
				},
				{ 
					headerText : "U/Price", 
					dataField : "unit_price", 
					width : "13%", 
					dataType : "numeric",
					style : "aui-right",
				},
				{ 
					headerText : "Amount", 
					dataField : "lc_total_amt", 
					width : "18%", 
					dataType : "numeric",
					style : "aui-right",
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						// 수량 * 단가 계산
						return ( item.qty * item.unit_price ); 
					}
				},
				{ 
					headerText : "Option", 
					dataField : "opt_name", 
					style : "aui-left"
				},
				{ 
					headerText : "선적발주일", 
					dataField : "ship_dt", 
					width : "12%", 
					style : "aui-center",
					dataType : "date",  
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "삭제", 
					dataField : "removeBtn",
					width : "6%", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if (regMemNo == memNo && lcStatus == 01) {
								var isRemoved = AUIGrid.isRemovedById(rightAuiGrid, event.item._$uid);
								if (isRemoved == false) {
// 									console.log("event : ", event);
									event.item.lc_total_amt = 0; // 행 삭제시 후 다시 추가시 합계 반영 안되는 문제로 0 세팅
									AUIGrid.updateRow(rightAuiGrid, event.item, event.rowIndex);
									AUIGrid.removeRow(event.pid, event.rowIndex);
									AUIGrid.update(rightAuiGrid);
									
									// 합계금액 세팅
									$M.setValue("total_amt", AUIGrid.getFooterData(rightAuiGrid)[2].text);
	
									// 선적발주내역에서 행 삭제시 생산발주내역으로 이동 하도록 작업.
									var leftAuiGridData = AUIGrid.getGridData(leftAuiGrid);
									var uptYn = "N";  // update, add flag 값
									for (var i = 0; i < leftAuiGridData.length; i++) {
										if( leftAuiGridData[i].machine_ship_no == event.item.machine_ship_no   
											&& leftAuiGridData[i].ship_seq_no == event.item.ship_seq_no
										) {
											var rowIdField = AUIGrid.getProp(leftAuiGrid, "rowIdField"); // 그리드 인덱스 구하기
											var rowIndex = AUIGrid.rowIdToIndex(leftAuiGrid, leftAuiGridData[i][rowIdField]); // 그리드 인덱스 구하기
											console.log("rowIndex : ", rowIndex);
											// 중복값 있음
											var item = {
													"lc_poss_qty" : leftAuiGridData[i].lc_poss_qty + event.item.qty,
													"qty" : 1
											}
											AUIGrid.updateRow(leftAuiGrid, item, rowIndex);
											uptYn = "Y"; //업데이트 된경우
										}
									}
									
									if (uptYn == "N") {
										// 중복값 없음
										// 행 삭제시 생산발주내역에 다시 추가
										event.item.lc_poss_qty = event.item["qty"]; // 생산발주잔여수량 세팅
										event.item.qty = 1; // 선적수량 1로 초기화
										AUIGrid.addRow(leftAuiGrid, event.item, 'last');
									}
									
								} else {
// 									AUIGrid.restoreSoftRows(rightAuiGrid, "selectedIndex"); 
// 									AUIGrid.update(rightAuiGrid);
								};
							}
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
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_name",
				}, 
				{
					dataField : "qty",
					positionField : "qty",
					operation : "SUM",
					style : "aui-center aui-footer"
				},
				{
					dataField : "lc_total_amt",
					positionField : "lc_total_amt",
					operation : "SUM",
					formatString : "#,##0.00",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(rightAuiGrid);
						var rowIdField = AUIGrid.getProp(rightAuiGrid, "rowIdField");
						var item;
						var sum = 0;
						for(var i=0, len=gridData.length; i<len; i++) {
							item = gridData[i];
							if(!AUIGrid.isRemovedById(rightAuiGrid, item[rowIdField])) {
								sum += item.lc_total_amt;
							} 
						}
						return sum;
					}
				},
			];
			rightAuiGrid = AUIGrid.create("#rightAuiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(rightAuiGrid, footerColumnLayout);
			AUIGrid.setGridData(rightAuiGrid, ${jsonList});
			$("#rightAuiGrid").resize();
		}
		
		// 선적발주 잔여수량
		var dataQty;
		
		// 체크 후 추가버튼
		function fnAddCheck() {
			// 체크한 그리드 데이터 리스트
			var data = AUIGrid.getCheckedRowItemsAll(leftAuiGrid);
			if (data.length == 0) {
				alert("선택된 항목이 없습니다.");
				return;
			}
			
			// 화면에 보여지는 그리드 데이터 목록
			var rightAuiGridData = AUIGrid.getGridData(rightAuiGrid);
			
			// 체크된 행의 수량 벨리데이션
			for (var item in data) {
				var uptYn = "N"; // update, add flag 값
				var rowIdField = AUIGrid.getProp(leftAuiGrid, "rowIdField"); // 그리드 인덱스 구하기
				var rowIndex = AUIGrid.rowIdToIndex(leftAuiGrid, data[item][rowIdField]); // 그리드 인덱스 구하기
				
				// 수량 벨리데이션
				if (data[item].lc_poss_qty < data[item].qty) {
					alert("LC수량이 선적발주잔여수량보다 클 수 없습니다.");
					fnSetCellFocus(leftAuiGrid, rowIndex, "qty");
					return;
				} else {
					// 선적발주내역으로 데이터 추가시 생산발주 잔여수량 수량 빼주는 작업.
					AUIGrid.updateRow(leftAuiGrid, {"lc_poss_qty" : data[item].lc_poss_qty - data[item].qty}, rowIndex);
 					
					// 생산발주 잔여수량이 0이되면 행 삭제
					dataQty = data[item].lc_poss_qty - data[item].qty;
					if (dataQty == 0) {
						AUIGrid.removeRow(leftAuiGrid, rowIndex);
						AUIGrid.update(leftAuiGrid);						
					}
					for (var i = 0; i < rightAuiGridData.length; i++) {
						if( rightAuiGridData[i].machine_ship_no == data[item].machine_ship_no   
							&& rightAuiGridData[i].ship_seq_no == data[item].ship_seq_no
						) {
							//우측 그리드에 이미 값이 있으면 수량 업데이트 후 for문을 나감							
							var rowIdField = AUIGrid.getProp(rightAuiGrid, "rowIdField"); // 그리드 인덱스 구하기
							var rowIndex = AUIGrid.rowIdToIndex(rightAuiGrid, rightAuiGridData[i][rowIdField]); // 그리드 인덱스 구하기
							var row = rightAuiGridData[i];
							var isRemoved = AUIGrid.isRemovedById(rightAuiGrid, row[rowIdField]); // 삭제한 행인지 여부
							// 삭제여부에따라 qty 컨트롤
							if (isRemoved == true) {
								AUIGrid.restoreSoftRows(rightAuiGrid, rowIndex);  // 삭제한 선적발주내역 삭제해제
								console.log(data[item]);
								AUIGrid.updateRow(rightAuiGrid, {"qty" : data[item].qty, "lc_total_amt" : data[item].qty * data[item].unit_price }, rowIndex);
							} else {
								AUIGrid.updateRow(rightAuiGrid, {"qty" : rightAuiGridData[i].qty + data[item].qty }, rowIndex);
							}
							uptYn = "Y"; //업데이트 된경우
						}						
					}
 					
					if(uptYn == "N"){
						data[item].seq_no = null;
						AUIGrid.addRow(rightAuiGrid, data[item], 'last');
					}
					// 합계금액 form에 세팅
					$M.setValue("total_amt", AUIGrid.getFooterData(rightAuiGrid)[2].text);
				}
			}
		}
		
		function goModify() {
			// 선적발주내역 벨리데이션
			var data = AUIGrid.getGridData(rightAuiGrid);
			var removedData = AUIGrid.getRemovedItems(rightAuiGrid); // 삭제내역

			// LC Open 추가내역이 삭제되었을때 LC가 최소 한개이상 있는지 확인
			if ((removedData.length !== 0 && data.length === removedData.length) || data.length === 0) {
				alert("LC-Open을 추가해주세요.");
				return;
			}

			if (confirm("수정하시겠습니까?") == false) {
				return false;
			}
			var frm = document.main_form;

			if($M.validation(frm) == false) {
				return;
			}

			var idx = 1;
			$("input[name='file_seq']").each(function() {
				// 첨부파일 중복 등록으로 인하여 체크 - 김경빈
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue('att_file_seq_' + idx, $(this).val());
				}
				idx++;
			});
			for(; idx <= fileCount; idx++) {
				$M.setValue('att_file_seq_' + idx, 0);
			}

			var sendIdx = 1;
			$("input[name='att_send_file_seq']").each(function() {
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue('send_file_seq_' + sendIdx, $(this).val());
				}
				sendIdx++;
			});
			for(; sendIdx <= sendFileCount; sendIdx++) {
				$M.setValue('send_file_seq_' + sendIdx, 0);
			}
			
			$M.setValue("file_change_yn", fileChangeYn);
			
			frm = $M.toValueForm(frm);

			var machineLcNo = $M.getValue("machine_lc_no");
			var gridForm = fnChangeGridDataToForm(rightAuiGrid);
			$M.copyForm(gridForm, frm);

			$M.goNextPageAjax(this_page + "/" + machineLcNo + "/modify", gridForm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("수정이 완료되었습니다.");
		    			if (window.opener && window.opener.goSearch) {
		    				window.opener.goSearch();
		    			}
		    			location.reload();
					}
				}
			);
		}
		
		function goRemove() {
			if (confirm("삭제하시겠습니까?") == false) {
				return false;
			}
			
			var machineLcNo = $M.getValue("machine_lc_no");
			var frm = $M.toValueForm(document.main_form);
			
			var concatCols = [];
			var concatList = [];
			var gridIds = [rightAuiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			
			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);
			
			$M.goNextPageAjax(this_page + "/" + machineLcNo + "/remove" , gridFrm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리 되었습니다.");
		    			fnClose();
		    			window.opener.goSearch();
					}
				}
			);	
		}
		
		function fnClose() {
			window.close();
		}
		
		// (SR:12052) invoice 날짜 입력시 송금기준일자로 송금예정일 구하기 - 황빛찬
		function fnChangeData(val) {
			var invoiceDate = val.replaceAll('-', '');  // 인보이스 날짜
			var sendMoneyDayCnt = $M.getValue("send_money_day_cnt");  // 송금유예일
			
			var param = {
					"invoice_dt" : invoiceDate,
					"send_money_day_cnt" : sendMoneyDayCnt
			}
			
			$M.goNextPageAjax("/sale/sale020301/planDt/", $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			console.log(result);
		    			$M.setValue("remit_plan_dt", result.remit_plan_dt);
					}
				}
			);	
		}

	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="send_money_day_cnt" name="send_money_day_cnt" value="${list[0].send_money_day_cnt}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<div class="doc-info" style="flex: 1;">				
					<h4>LC Open상세</h4>			
				</div>		
			</div>	
<!-- 상단 폼테이블 -->	
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="120px">
						<col width="">
						<col width="120px">
						<col width="">
						<col width="120px">
						<col width="">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">관리번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control" readonly id="machine_lc_no" name="machine_lc_no" value="${list[0].machine_lc_no}">
									</div>
								</div>
							</td>
							<th class="text-right">등록일</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-4">
										<input type="text" class="form-control width80px" id="lc_dt" name="lc_dt" alt="등록일" value="${list[0].lc_dt}" readonly required="required" dateformat="yyyy-MM-dd">
									</div>
								</div>
							</td>
							<th class="text-right">담당자</th>
							<td>
								<input type="text" class="form-control width80px" id="reg_mem_name" name="reg_mem_name" value="${list[0].reg_mem_name}" readonly alt="담당자"  required="required">
								<input type="hidden" name="reg_id" id="reg_id" value="${list[0].reg.mem_no}" >
							</td>
							<th class="text-right">참고</th>
							<td>
								<input type="text" class="form-control with280px" maxlength="80" id="desc_text" name="desc_text" value="${list[0].desc_text}">
							</td>
						</tr>
						<tr>
							<th class="text-right">To</th>
							<td>
								<input type="text" class="form-control width140px" id="cust_name" name="cust_name" readonly alt="To"  required="required" value="${list[0].cust_name}">
								<input type="hidden" id="client_cust_no" name="client_cust_no" value="${list[0].client_cust_no}">
							</td>
							<th class="text-right">합계금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-7">
										<input type="text" class="form-control text-right" readonly name="total_amt" id="total_amt" format="decimal" datatype="int" alt="합계금액"  required="required" value="${list[0].total_amt}">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right essential-item">입고예정</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control width100px essential-bg calDate" id="in_plan_dt" name="in_plan_dt" dateformat="yyyy-MM-dd" value="${list[0].in_plan_dt}" alt="입고예정일" required="required">
								</div>
							</td>
							<th class="text-right essential-item">송금예정</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 essential-bg width100px calDate" id="remit_plan_dt" name="remit_plan_dt" dateformat="yyyy-MM-dd" alt="송금예정일" value="${list[0].remit_plan_dt}" required="required">
									<span>
										<button type="button" id="btnPaper" class="btn btn-primary-gra mr10" onclick="javascript:goRequestPaper();" style="margin-left: 5px; border-radius: 4px;">관리부요청쪽지발송</button>
									</span>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">출발예정일(ETD)</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 essential-bg width100px calDate" id="etd" name="etd" dateformat="yyyy-MM-dd" alt="출발예정일(ETD)" required="required" value="${list[0].etd}">
								</div>
							</td>
							<th class="text-right essential-item">도착예정일(ETA)</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 essential-bg width100px calDate" id="eta" name="eta" dateformat="yyyy-MM-dd" alt="도착예정일(ETA)" required="required" value="${list[0].eta}">
								</div>
							</td>
							<th class="text-right">Invoice Date</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width100px calDate" id="invoice_dt" name="invoice_dt" dateformat="yyyy-MM-dd" alt="Invoice Date" value="${list[0].invoice_dt}" onchange="javascript:fnChangeData(this.value);">
								</div>
							</td>
							<th class="text-right">비고</th>
							<td>
								<input type="text" class="form-control with280px" maxlength="80" id="ship_remark" name="ship_remark" value="${list[0].ship_remark}">
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
<!-- 하단 폼테이블 -->		
			<div class="row">					
<!-- 좌측 폼테이블 -->
				<div class="col-6">
<!-- 생산발주내역 -->
					<div class="title-wrap mt10">
						<h4>선적발주내역</h4>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>									
					</div>

					<div id="leftAuiGrid" style="margin-top: 5px; height: 450px;">
					</div>
<!-- /생산발주내역 -->
				</div>
<!-- /좌측 폼테이블 -->
<!-- 우측 폼테이블 -->
				<div class="col-6">
<!-- 옵션품목 -->
					<div class="title-wrap mt10">
						<h4>LC-Open추가내역</h4>
					</div>
					<div id="rightAuiGrid" style="margin-top: 5px; height: 450px;">
					</div>
<!-- /옵션품목 -->
				</div>
<!-- /우측 폼테이블 -->
			</div>
<!-- /하단 폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
				<!-- 수정,삭제,닫기 -->
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
						<jsp:param name="mem_no" value="${list[0].reg_mem_no}"/>
					</jsp:include>
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
<%--<input type="hidden" id="cmd" name="cmd" value="C">--%>
</form>
</body>
</html>