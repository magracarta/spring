<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > 장비대장관리-선적 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var jsonList = ${jsonList}  // lc 데이터
		var machineList = ${machineList}  // 차대번호 등록내역 데이터
		var regMemNo = jsonList[0].reg_mem_no;
		var memNo = '${SecureUser.mem_no}';
		var machineList; // 장비(모델) 데이터 (차대번호 등록 팝업에 넘길 데이터)
		var bodyList; // 차대번호등록내역 데이터 (차대번호 등록 팝업에 넘길 데이터)
		var auiGridMiddle;
		var auiGridBottom;
		var fileIdx; // 파일업로드 index
		
		var parentMachineList // 발주내역 그리드 데이터 (장비별로 담아 차대번호등록팝업에 넘길 부모 list)
		var parentBodyList // 차대번호등록내역 그리드 데이터 (장비별로 담아 차대번호등록팝업에 넘길 부모 list)
		var bodySetList; // 차대번호 등록할 장비 list

		var parentBodyNoList; // 차대번호 중복체크위한 변수
		
		$(document).ready(function() {
			// 발주내역 그리드 생성
			createMiddleAUIGrid();
			// 차대번호 등록내역 그리드 생성
			createBottomAUIGrid();
			
			console.log(parentMachineList);
			console.log("jsonList : ", jsonList);
			console.log("machineList : ", machineList);
			
			fnSetFileInfo();
		});
		
		//그리드생성
		function createMiddleAUIGrid() {
			var gridProsMiddle = {
					rowIdField : "seq_no",
					// rowNumber 
					showRowNumColumn: false,
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
			};
			// 컬럼레이아웃
			var columnLayoutMiddle = [
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{ 
					dataField : "opt_code", 
					visible : false
				},
				{ 
					headerText : "선적발주번호", 
					dataField : "machine_ship_no", 
					width : "11%", 
					style : "aui-center aui-popup",
				},
				{ 
					headerText : "PART NO", 
					dataField : "machine_name", 
					width : "11%", 
					style : "aui-center",
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
					width : "11%", 
					style : "aui-right",
				},
				{ 
					headerText : "Amount", 
					dataField : "ship_total_amt", 
					dataType : "numeric",
					width : "15%", 
					style : "aui-right",
				},
				{ 
					headerText : "Option", 
					dataField : "opt_name", 
					width : "30%", 
					style : "aui-left",
				},
				{ 
					headerText : "선적수", 
					dataField : "machine_qty", 
					width : "5%", 
					style : "aui-center",
				},
				{ 
					headerText : "등록시간", 
					dataField : "reg_date", 
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					style : "aui-center",
				}
			];
			
			auiGridMiddle = AUIGrid.create("#auiGridMiddle", columnLayoutMiddle, gridProsMiddle);
			AUIGrid.setGridData(auiGridMiddle, ${jsonList});
			AUIGrid.bind(auiGridMiddle, "cellClick", function(event) {
				if(event.dataField == 'machine_ship_no') {
					var machinePlantSeq = event.item.machine_plant_seq;
					console.log("machinePlantSeq : ", machinePlantSeq);
					
					parentMachineList = [];  // 선택한 장비를 모두 담을 부모 list
					for (var i = 0; i < jsonList.length; i++) {
						if (machinePlantSeq == jsonList[i].machine_plant_seq) {
							parentMachineList.push(jsonList[i]);  // 선택한 장비와 LC안에있는 같은 장비들을 모두 담아서 차대번호등록팝업으로 넘겨준다.
						}
					}
					
					var bottomGridData = AUIGrid.getGridData(auiGridBottom);
					console.log("bottomGridData : ", bottomGridData);
					
					parentBodyNoList = [];
					for (var i = 0; i < bottomGridData.length; i++) {
						parentBodyNoList.push(bottomGridData[i].body_no);
					}

					console.log("parentBodyNoList ??????????? -->>  ", parentBodyNoList);
					
					parentBodyList = [];    // 차대번호등록 list중 선택한장비와 같은 장비들만 담을 list
					for (var i = 0; i < bottomGridData.length; i++) {
						if (machinePlantSeq == bottomGridData[i].machine_plant_seq) {
							console.log("bottomGridData[i] : ", bottomGridData[i]);
							parentBodyList.push(bottomGridData[i]); // 차대번호 등록내역중 클릭한 장비와 같은 것들.
						}
					}
					
					console.log("parentMachineList : ", parentMachineList);
					console.log("parentBodyList", parentBodyList);
					
					bodySetList = []; // 차대번호등록팝업으로 보내줄 list (차대번호 등록 가능한 장비 list)
					var gridData = AUIGrid.getGridData(auiGridMiddle);
					// 자식창으로 넘길 배열 만들기
					// 발주내역그리드에서 차대번호등록그리드 에 있는 row를 뺴주고 담아준다.
					for (var i = 0; i < gridData.length; i++) {
						if (gridData[i].machine_plant_seq == machinePlantSeq 
								&& gridData[i].qty - gridData[i].machine_qty != 0) {
// 							console.log("gridData[i] :: ", gridData[i]);
							bodySetList.push(gridData[i]);
						}
						
					}
					console.log("bodySetList : ", bodySetList);
					
					var params = {
// 							machine_lc_no : event.item.machine_lc_no,
							machine_plant_seq : event.item.machine_plant_seq,
							opt_code : event.item.opt_code
					};
					// 장비입고-LC Open선적 차대번호등록 팝업
					var popupOption = "";
					$M.goNextPage('/sale/sale0203p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
			$("#auiGridMiddle").resize();
		}
		
		function createBottomAUIGrid() {
			var gridProsBottom = {
					rowIdField : "machine_seq",
					showRowNumColumn: true
			};
			var columnLayoutBottom = [
				{ 
					dataField : "machine_seq", 
					visible : false
				},
				{ 
					dataField : "container_seq", 
					visible : false
				},
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "machine_lc_no", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{ 
					dataField : "in_org_code", 
					visible : false
				},
				{ 
					dataField : "center_org_code", 
					visible : false
				},
				{ 
					dataField : "driver_name", 
					visible : false
				},
				{ 
					dataField : "driver_hp_no", 
					visible : false
				},
				{ 
					dataField : "car_date2", 
					visible : false
				},
				{ 
					dataField : "center_confirm_yn", 
					visible : false
				},
				{ 
					dataField : "container_change_flag", 
					visible : false
				},
				{ 
					dataField : "opt_no_2", 
					visible : false
				},
				{ 
					dataField : "opt_model_2", 
					visible : false
				},
				{ 
					dataField : "engine_no_2", 
					visible : false
				},
				{ 
					dataField : "engine_model_1", 
					visible : false
				},
				{ 
					dataField : "engine_model_2", 
					visible : false
				},
				{ 
					headerText : "PART NO.", 
					dataField : "machine_name", 
					width : "9%",
					style : "aui-center"
				},
				{
					headerText : "외화단가",
					dataField : "unit_price",
					dataType : "numeric",
					formatString : "#,##0.00",
					width : "9%",
					style : "aui-right"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "9%", 
					style : "aui-center"
				},
				{ 
					headerText : "엔진번호", 
					dataField : "engine_no_1", 
					width : "9%", 
					style : "aui-center"
				},
				{ 
					headerText : "옵션모델1", 
					dataField : "opt_model_1", 
					width : "9%", 
					style : "aui-center"
				},
				{ 
					headerText : "옵션번호1", 
					dataField : "opt_no_1", 
					width : "9%", 
					style : "aui-center"
				},
				{ 
					headerText : "선적일자", 
					dataField : "ship_dt", 
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					width : "9%", 
					style : "aui-center"
				},
				{ 
					headerText : "예정일자", 
					dataField : "port_plan_dt", 
					width : "9%", 
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "발주번호", 
					dataField : "machine_ship_no",
					width : "9%", 
					style : "aui-center"
				},
				{ 
					headerText : "컨테이너명", 
					dataField : "container_name",
					style : "aui-center"
				},
				{ 
					headerText : "입고센터", 
					dataField : "center_org_name", 
					style : "aui-center"
				},
// 				{ 
// 					headerText : "비고", 
// 					dataField : "remark", 
// 					style : "aui-left"
// 				},
				{ 
					headerText : "비고", 
					dataField : "lc_remark", 
					style : "aui-left"
				},
			];
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayoutBottom, gridProsBottom);
			AUIGrid.setGridData(auiGridBottom, ${machineList});
			$("#auiGridBottom").resize(); 
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
			var colSizeList = AUIGrid.getFitColumnSizeList(auiGridBottom, true);
		    AUIGrid.setColumnSizeList(auiGridBottom, colSizeList);
		};
		
		//팝업 끄기
		function fnClose() {
			window.close(); 
		}
		
		// 차대번호등록팝업에서 받아온 차대번호등록내역 그리드 data
		function fnSetMachineBodyList(result1, result2) {
			console.log("팝업에서 받아온 추가 데이터 : ", result1);
			console.log("팝업에서 받아온 변경 데이터 : ", result2);
			
			for (var i = 0; i < result2.length; i++) {
				var rowIdField = AUIGrid.getProp(auiGridBottom, "rowIdField");
				var rowIndex = AUIGrid.rowIdToIndex(auiGridBottom, result2[i][rowIdField]);
				console.log("rowIndex :: ", rowIndex);
				
				// 변경된 데이터 update
				AUIGrid.updateRow(auiGridBottom, result2[i], rowIndex);
			}
			
			// 추가된 데이터 add
			AUIGrid.addRow(auiGridBottom, result1, 'last');
		
			for (var i = 0; i < result1.length; i++) {
				// 선적수 + 연산
				var rowIdField = AUIGrid.getProp(auiGridMiddle, "rowIdField");
				var rowIndex = AUIGrid.rowIdToIndex(auiGridMiddle, result1[i][rowIdField]);
// 				console.log("발주내역 rowIndex : ", rowIndex);
	
				var machineQtyValue = AUIGrid.getCellValue(auiGridMiddle, rowIndex, "machine_qty");
// 				console.log("machineQtyValue : ", machineQtyValue);
				
				AUIGrid.updateRow(auiGridMiddle, {"machine_qty" : machineQtyValue + result1[i].machine_qty}, rowIndex);
			}
		}
		
		// 차대번호일괄등록 데이터 세팅.
		function fnSetMachineBodyAllList(list) {
			console.log("list : ", list);
			
			for (var i = 0; i < list.length; i++) {
				var rowIdField = AUIGrid.getProp(auiGridBottom, "rowIdField");
				var rowIndex = AUIGrid.rowIdToIndex(auiGridBottom, list[i][rowIdField]);
				console.log("rowIndex :: ", rowIndex);
				
				if (rowIndex == -1) {
					// 추가된 데이터 add
					AUIGrid.addRow(auiGridBottom, list[i], 'last');
				}
				// 변경된 데이터 update
				AUIGrid.updateRow(auiGridBottom, list[i], rowIndex);
			}
		}
		
		function goContainer() {
			var params = {
					machine_lc_no : $M.getValue("machine_lc_no")
			};
			var popupOption = "";
			// 장비입고-LC Open선적 컨테이너설정 팝업
			$M.goNextPage('/sale/sale0203p03', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		function goPopupCenter() {
// 			var params = {
// 					machine_lc_no : $M.getValue("machine_lc_no")
// 			};
// 			var popupOption = "";
// 			// 장비입고-LC Open선적 입고센터지정 팝업
// 			$M.goNextPage('/sale/sale0203p04', $M.toGetParam(params), {popupStatus : popupOption});
			
			// 2.5차 추가. 입고센터지정팝업 변경.
			var params = {};
			var popupOption = "";
			// 장비입고-LC Open선적 입고센터지정 팝업
			$M.goNextPage('/sale/sale0203p07', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		function goSave() {
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var machine_seq = [];
			var machine_plant_seq = [];
            var body_no = [];
            var engine_no_1 = [];
            var engine_no_2 = [];
            var engine_model_1 = [];
            var engine_model_2 = [];
            var opt_model_1 = [];
            var opt_model_2 = [];
            var opt_no_1 = [];
            var opt_no_2 = [];
            var machine_lc_no = [];
            var seq_no = [];
            var container_seq = [];
            var driver_name = [];
            var driver_hp_no = [];
            var in_org_code = [];
            var remark = [];
            var shipDt = [];
            var machine_cmd = [];
            
            var addGridData = AUIGrid.getAddedRowItems(auiGridBottom);  // 추가내역
            var changeGridData = AUIGrid.getEditedRowItems(auiGridBottom); // 변경내역

            console.log("addGridData : ", addGridData);
            console.log("changeGridData : ", changeGridData);
            
            for (var i = 0; i < addGridData.length; i++) {
            	machine_seq.push(addGridData[i].machine_seq);
            	machine_plant_seq.push(addGridData[i].machine_plant_seq);
            	body_no.push(addGridData[i].body_no);
            	engine_no_1.push(addGridData[i].engine_no_1);
            	engine_no_2.push(addGridData[i].engine_no_2);
            	engine_model_1.push(addGridData[i].engine_model_1);
            	engine_model_2.push(addGridData[i].engine_model_2);
            	opt_model_1.push(addGridData[i].opt_model_1);
            	opt_model_2.push(addGridData[i].opt_model_2);
            	opt_no_1.push(addGridData[i].opt_no_1);
            	opt_no_2.push(addGridData[i].opt_no_2);
            	machine_lc_no.push(addGridData[i].machine_lc_no);
            	seq_no.push(addGridData[i].seq_no);
            	container_seq.push(addGridData[i].container_seq);
            	driver_name.push(addGridData[i].driver_name);
            	driver_hp_no.push(addGridData[i].driver_hp_no);
            	in_org_code.push(addGridData[i].in_org_code);
            	remark.push(addGridData[i].lc_remark);
            	shipDt.push(addGridData[i].ship_dt.replace(/-/gi, ""));
            	machine_cmd.push("C");
            }
            
            for (var i = 0; i < changeGridData.length; i++) {
            	machine_seq.push(changeGridData[i].machine_seq);
            	machine_plant_seq.push(changeGridData[i].machine_plant_seq);
            	body_no.push(changeGridData[i].body_no);
            	engine_no_1.push(changeGridData[i].engine_no_1);
            	engine_no_2.push(changeGridData[i].engine_no_2);
            	engine_model_1.push(changeGridData[i].engine_model_1);
            	engine_model_2.push(changeGridData[i].engine_model_2);
            	opt_model_1.push(changeGridData[i].opt_model_1);
            	opt_model_2.push(changeGridData[i].opt_model_2);
            	opt_no_1.push(changeGridData[i].opt_no_1);
            	opt_no_2.push(changeGridData[i].opt_no_2);
            	machine_lc_no.push(changeGridData[i].machine_lc_no);
            	seq_no.push(changeGridData[i].seq_no);
            	container_seq.push(changeGridData[i].container_seq);
            	driver_name.push(changeGridData[i].driver_name);
            	driver_hp_no.push(changeGridData[i].driver_hp_no);
            	in_org_code.push(changeGridData[i].in_org_code);
            	remark.push(changeGridData[i].lc_remark);
            	shipDt.push(changeGridData[i].ship_dt.replace(/-/gi, ""));
            	machine_cmd.push("U");
            }
            
			var option = {
					isEmpty : true
			};

			$M.setValue(frm, "machine_seq_str", $M.getArrStr(machine_seq, option));
			$M.setValue(frm, "machine_plant_seq_str", $M.getArrStr(machine_plant_seq, option));
			$M.setValue(frm, "body_no_str", $M.getArrStr(body_no, option));
			$M.setValue(frm, "engine_no_1_str", $M.getArrStr(engine_no_1, option));
			$M.setValue(frm, "engine_no_2_str", $M.getArrStr(engine_no_2, option));
			$M.setValue(frm, "engine_model_1_str", $M.getArrStr(engine_model_1, option));
			$M.setValue(frm, "engine_model_2_str", $M.getArrStr(engine_model_2, option));
			$M.setValue(frm, "opt_model_1_str", $M.getArrStr(opt_model_1, option));
			$M.setValue(frm, "opt_model_2_str", $M.getArrStr(opt_model_2, option));
			$M.setValue(frm, "opt_no_1_str", $M.getArrStr(opt_no_1, option));
			$M.setValue(frm, "opt_no_2_str", $M.getArrStr(opt_no_2, option));
			$M.setValue(frm, "machine_lc_no_str", $M.getArrStr(machine_lc_no, option));
			$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no, option));
			$M.setValue(frm, "container_seq_str", $M.getArrStr(container_seq, option));
			$M.setValue(frm, "driver_name_str", $M.getArrStr(driver_name, option));
			$M.setValue(frm, "driver_hp_no_str", $M.getArrStr(driver_hp_no, option));
			$M.setValue(frm, "in_org_code_str", $M.getArrStr(in_org_code, option));
			$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "ship_dt_str", $M.getArrStr(shipDt, option));
			$M.setValue(frm, "machine_cmd_str", $M.getArrStr(machine_cmd, option));
			
			console.log("결과 ? -> ", frm);
			
			$M.goNextPageAjaxSave(this_page + "/save", frm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("저장이 완료되었습니다.");
		    			opener.goSearch();
		    			location.reload();
// 						fnClose();
					}
				}
			);
		}
		
		// 파일찾기 팝업
		function goSearchFile(idx) {
			fileIdx = idx;
			var param = {
				upload_type	: "MACHINE",
				file_type : "both",
			};
			openFileUploadPanel('setFileInfo', $M.toGetParam(param));
		}
		
		// 팝업창에서 받아온 값
		function setFileInfo(result) {
			console.log("result : ", result);
// 			fileIdx = result.fileIdx;
			console.log("fileIdx : ", fileIdx);
			$("#file_name_item_div"+fileIdx).remove();
			showFileNameTd(fileIdx);
			var fileName; // 파일업로드 대상 컬럼 name값
			var str = '';
			str += '<div class="table-attfile-item'+fileIdx+'" id="file_name_item_div'+fileIdx+'">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			if (fileIdx == 1) {
				fileName = "cargo_insu_file_seq"
			} else if (fileIdx == 2) {
				fileName = "invoice_file_seq"
			} else if (fileIdx == 3) {
				fileName = "pklist_file_seq"
			} else if (fileIdx == 4) {
				fileName = "landing_file_seq"
			}
			console.log("fileName : ", fileName);
			str += '<input type="hidden" id="file_seq" name="'+fileName+'" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile('+fileIdx+');"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$("#file_name_div"+fileIdx).append(str);
		}
		
		// 이미지 삭제
		function fnRemoveFile(fileIdx) {
			var result = confirm("이미지파일을 삭제하시겠습니까?");
			if (result) {
				console.log(fileIdx);
				showFileSearchTd(fileIdx);
// 				$("#file_name_item_div"+fileIdx).remove();
				$("#file_name_item_div"+fileIdx +" input").val("0");
			} else {
				return false;
			}
		}
		
		// 파일찾기 버튼 노출
		function showFileSearchTd(fileIdx) {
			$("#file_search_td"+fileIdx).removeClass("dpn");
			$("#file_name_td"+fileIdx).addClass("dpn");
		}
		
		// 파일명 노출
		function showFileNameTd(fileIdx) {
			$("#file_search_td"+fileIdx).addClass("dpn");
			$("#file_name_td"+fileIdx).removeClass("dpn");
		}
		
		// 파일업로드 정보
		function fnSetFileInfo() {
			var item = jsonList[0]
			if ("" == item.cargo_insu_file_seq || "" == item.cargo_insu_file_name) {
				showFileSearchTd(1);
			} else {
				fileIdx = 1;
				var file_info = {
						"file_seq" : item.cargo_insu_file_seq,
						"file_name" : item.cargo_insu_file_name,
						"fileIdx" : fileIdx
				};
				setFileInfo(file_info);
				showFileNameTd();
			} 
			
			if ("" == item.invoice_file_seq || "" == item.invoice_file_name){
				showFileSearchTd(2);
			} else {
				fileIdx = 2;
				var file_info = {
						"file_seq" : item.invoice_file_seq,
						"file_name" : item.invoice_file_name,
						"fileIdx" : fileIdx
				};
				setFileInfo(file_info);
				showFileNameTd();
			} 
			
			if ("" == item.pklist_file_seq || "" == item.pklist_file_name){
				showFileSearchTd(3);
			} else {
				fileIdx = 3;
				var file_info = {
						"file_seq" : item.pklist_file_seq,
						"file_name" : item.pklist_file_name,
						"fileIdx" : fileIdx
				};
				setFileInfo(file_info);
				showFileNameTd();
			} 
			
			if ("" == item.landing_file_seq || "" == item.landing_file_name){
				showFileSearchTd(4);
			} else {
				fileIdx = 4;
				var file_info = {
						"file_seq" : item.landing_file_seq,
						"file_name" : item.landing_file_name,
						"fileIdx" : fileIdx
				};
				setFileInfo(file_info);
				showFileNameTd();
			} 
		}
		
		// 차대번호 일괄등록(2.5차 추가)
		function fnAddBodyNo() {
			var changeCnt = fnChangeGridDataCnt(auiGridBottom);
			if (changeCnt > 0) {
				alert("변경사항을 저장 후 시도해 주세요.");
				return;
			}
			
			var param = {
					machine_lc_no : $M.getValue("machine_lc_no")
			};

			var popupOption = "";
			$M.goNextPage('/sale/sale0203p10', $M.toGetParam(param), {popupStatus: popupOption});
		}

		// 차대번호 일괄등록(컨테이너) (3차 개선 추가)
		function fnAddBodyNoContainer() {
			var changeCnt = fnChangeGridDataCnt(auiGridBottom);
			if (changeCnt > 0) {
				alert("변경사항을 저장 후 시도해 주세요.");
				return;
			}

			var param = {
				machine_lc_no : $M.getValue("machine_lc_no")
			};

			// 팝업 오픈전, 컨테이너명 중복 있는지 체크.
			$M.goNextPageAjax(this_page + "/container/duplCheck" , $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						// 컨테이너명 중복 없을시 팝업 오픈
						var popupOption = "";
						$M.goNextPage('/sale/sale0203p11', $M.toGetParam(param), {popupStatus: popupOption});
					}
				}
			);
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" name="money_unit_cd" value="${list[0].money_unit_cd}">
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
					<h4>장비대장관리-선적</h4>		
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
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">관리번호</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-4">
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
									<td>
										${list[0].machine_lc_status_name}
									</td>
								</tr>
								<tr>
									<th class="text-right">To</th>
									<td>
										<input type="text" class="form-control width140px" id="cust_name" name="cust_name" readonly alt="To"  required="required" value="${list[0].cust_name}">
										<input type="hidden" id="client_cust_no" name="client_cust_no" value="${list[0].client_cust_no}">
									</td>
									<th rowspan="2" class="text-right">From</th>
									<td rowspan="2">
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" class="form-control" id="mem_eng_name" name="mem_eng_name" alt="From"  required="required" value="${list[0].mem_eng_name}" readonly>
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="job_eng_name" name="job_eng_name" value="${list[0].job_eng_name}">
											</div>
										</div>
									</td>
									<th rowspan="5" class="text-right">Remark</th>
									<td rowspan="5">
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_1" name="remark_1" alt="Remark"  required="required" value="${list[0].remark_1}">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_2" name="remark_2" value="${list[0].remark_2}">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_3" name="remark_3" value="${list[0].remark_3}">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_4" name="remark_4" value="${list[0].remark_4}">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_5" name="remark_5" value="${list[0].remark_5}">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" readonly id="remark_6" name="remark_6" value="${list[0].remark_6}">
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">Attn</th>
									<td>
										<input type="text" class="form-control" readonly id="client_charge_name" name="client_charge_name" alt="Attn"  required="required" value="${list[0].client_charge_name}">
									</td>
								</tr>
								<tr>
									<th class="text-right">CC</th>
									<td>
										<input type="text" class="form-control" readonly id="client_rep_name" name="client_rep_name" alt="CC"  required="required" value="${list[0].client_rep_name}">
									</td>
									<th class="text-right">RE</th>
									<td>
										<input type="text" class="form-control" readonly id="order_remark" name="order_remark" alt="RE"  required="required" value="${list[0].order_remark}">
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
									<th class="text-right">합계금액</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<input type="text" class="form-control text-right" readonly name="total_amt" id="total_amt" format="decimal" datatype="int" alt="합계금액"  required="required" value="${list[0].total_amt}">
											</div>
											<div class="col-3">원</div>
										</div>
									</td>	
								</tr>
								<tr>
									<th class="text-right">참고</th>
									<td colspan="3">
										<input type="text" class="form-control" readonly id="desc_text" name="desc_text" value="${list[0].desc_text}">
										<input type="hidden" id="lc_remark" name="lc_remark" value="${list[0].desc_text}">
									</td>
								</tr>
							</tbody>
						</table>
						
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">적하보험</th>
									<td id="file_search_td1">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(1)">파일찾기</button>
									</td>	
									<td id="file_name_td1" class="dpn">
										<div class="table-attfile" id="file_name_div1">
										</div>
									</td>										
									<th class="text-right">Invoice</th>
									<td id="file_search_td2">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(2)">파일찾기</button>
									</td>	
									<td id="file_name_td2" class="dpn">
										<div class="table-attfile" id="file_name_div2">
										</div>
									</td>										
									<th class="text-right">P.K List</th>
									<td id="file_search_td3">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(3)">파일찾기</button>
									</td>	
									<td id="file_name_td3" class="dpn">
										<div class="table-attfile" id="file_name_div3">
										</div>
									</td>										
									<th class="text-right">Bill of landing</th>
									<td id="file_search_td4">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchFile(4)">파일찾기</button>
									</td>	
									<td id="file_name_td4" class="dpn">
										<div class="table-attfile" id="file_name_div4">
										</div>
									</td>										
								</tr>
							</tbody>
						</table>
					</div>
<!-- /상단 폼테이블 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div> 
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- 발주내역 -->
					<div>
						<div class="title-wrap mt10">
							<h4>발주내역</h4>
						</div>
						<div id="auiGridMiddle" style="margin-top: 5px; height: 240px;"></div>
					</div>
<!-- /발주내역 -->
<!-- 발주내역 -->
					<div>
						<div class="title-wrap mt10">
							<h4>차대번호등록내역</h4>
							<div class="btn-group mt5">						
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
								</div>
							</div>
						</div>
						<div id="auiGridBottom" style="margin-top: 5px; height: 240px;"></div>
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
</form>
</body>
</html>