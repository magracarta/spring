<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > 장비대장관리-선적 > 차대번호등록
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var machineList = opener.parentMachineList; // 장비(모델) list  
		var bodyList = opener.parentBodyList;   // 차대번호등록내역 list
		var bodySetList = opener.bodySetList;  // 차대번호등록내역 진행할 장비 정보 list
		
		var parentBodyNoList = opener.parentBodyNoList;
		
		var qty = 0; // 발주수량
		var machineQty = bodyList.length; // 선적수량 
		var cnt = 0;  // 차대번호등록내역에 추가시 다음모델 세팅을 위한 count 변수
		var index = 0; // 추가시 다음모델 세팅 반복문의 인덱스값
		var optPartList = ${optPartList}
		
		$(document).ready(function() {
			// 옵션품목 그리드생성
			createMiddleAUIGrid();
			// 차대번호 등록내역 그리드 생성
			createBottomAUIGrid();
			for (var i = 0; i < machineList.length; i++) {
				qty += machineList[i].qty;
			}
			
			$("#qty").text(qty);  // 발주수량 세팅
			$("#machine_qty").text(machineQty); // 선적수량 세팅
			console.log("bodyList : ", bodyList);
			
			fnInit();
			
			console.log("parentBodyNoList ? ", parentBodyNoList);
		});
		
		// 장비목록중 첫번째 부품 정보 세팅
		function fnInit() {
			if (bodySetList.length != 0) {
				cnt = bodySetList[0].machine_qty;  // 다음모델로 넘기기위한 초기 cnt 설정
				// 부모창에서 넘겨준 등록예정 list 세팅하기
				$M.setValue("machine_name", bodySetList[0].machine_name);  // 모델명
				$("#machine_lc_status_name").text(bodySetList[0].machine_lc_status_name); // LC상태
				$M.setValue("machine_plant_seq", bodySetList[0].machine_plant_seq);
				$M.setValue("machine_lc_no", bodySetList[0].machine_lc_no);
				$M.setValue("machine_ship_no", bodySetList[0].machine_ship_no);
				$M.setValue("seq_no", bodySetList[0].seq_no);
				$M.setValue("unit_price", bodySetList[0].unit_price);

				
				console.log("bodySetList : ", bodySetList);
				console.log("optPartList : ", optPartList);
// 				console.log(optPartList[0].opt_code);
				// 옵션품목 그리드에 옵션품목 세팅
				if (bodySetList[0].part_no != "") {
// 					AUIGrid.setGridData(auiGridMiddle, bodySetList[0]);
					AUIGrid.setGridData(auiGridMiddle, ${optPartList});
					if (optPartList.length != 0) {
						$M.setValue("s_opt_code", optPartList[0].opt_code);
					}
				}
				
				// 컨테이너 목록 불러와서 selectbox에 세팅
				var machineLcNo = bodySetList[0].machine_lc_no;
				var param = {
						"machine_lc_no" : machineLcNo
				}
				
				$M.goNextPageAjax(this_page + "/containerList/search/" + bodySetList[0].machine_lc_no , "", {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			console.log("result : ", result);
			    			var containerList = result.list;
			    			
			    			var center_org_name; // 컨테이너에 매핑된 센터명
			    			$("#container_seq").append(new Option('- 선택 -', ""));
			    			for (item in containerList) {
			    				// 센터명 가공 : 있으면 센터명 없으면 공백
			    				if (containerList[item].center_org_name == undefined) {
			    					center_org_name = "";
			    				} else {
			    					center_org_name = "(" + containerList[item].center_org_name + ")";
			    				}
			    				$("#container_seq").append(new Option(containerList[item].container_name + center_org_name, containerList[item].container_seq));
			    			}
						}
					}
				);
			}
		}
		
		// 추가버튼 클릭시 다음 장비정보 차대번호등록 form에 세팅
		function fnNextMachineInfo() {
			cnt++;  // 모델 lc_qty 와 비교하기위한 count 변수
			
			// 다음 장비(모델) 세팅작업
			$M.clearValue({field : ["body_no", "engine_model_2", "engine_no_1", "engine_no_2", "opt_model_1", "opt_model_2", "opt_no_1", "opt_no_2", "lc_remark"]});
			AUIGrid.clearGridData(auiGridMiddle);
			$("#ship_dt").empty();
			$("#port_plan_dt").empty();
			$("#car_date2").empty();
			$("#driver_name").empty();
			$("#driver_hp_no").empty();
			$M.setValue("container_name", "");
			$M.setValue("container_seq", "");
			$M.setValue("in_org_code", "");
			$M.setValue("in_org_name", "");
			$M.setValue("driver_name", "");
			$M.setValue("driver_hp_no", "");
			$M.setValue("center_org_name", "");			
			$M.setValue("center_org_code", "");			
			$M.setValue("s_opt_code", "");
			$M.setValue("unit_price", "");
			machineQty++; // 선적수량 증가
			$("#machine_qty").text(machineQty);
			
			if (bodySetList[index].qty == cnt) {
				index++;
				cnt = 0;
			}
			
			var nextItem = bodySetList[index];
			if (nextItem != undefined) {
				$M.setValue("machine_name", nextItem.machine_name);
				$("#machine_lc_status_name").text(nextItem.machine_lc_status_name);
				$M.setValue("machine_plant_seq", nextItem.machine_plant_seq);
				$M.setValue("machine_lc_no", nextItem.machine_lc_no);
				$M.setValue("machine_ship_no", nextItem.machine_ship_no);
				$M.setValue("seq_no", nextItem.seq_no);
				$M.setValue("s_opt_code", nextItem.opt_code);
				$M.setValue("unit_price", nextItem.unit_price);
			}
			
			console.log("bodySetList[index] : ", bodySetList[index]);
			if (bodySetList[index] != undefined) {
				var optCode = bodySetList[index].opt_code;
				var machinePlantSeq = bodySetList[index].machine_plant_seq;
				
				var param = {
					opt_code : optCode,
					machine_plant_seq : machinePlantSeq,
				}
				
				$M.goNextPageAjax(this_page + "/opt/detail" , $M.toGetParam(param) , {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			console.log("result : ", result);
				    		AUIGrid.setGridData(auiGridMiddle, result.optPartList);
						}
					}
				);
			}
		}
		
		//그리드생성
		function createMiddleAUIGrid() {
			var gridProsMiddle = {
					rowIdField : "row",
					// rowNumber 
					showRowNumColumn: true,
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
			};
			// 컬럼레이아웃
			var columnLayoutMiddle = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "30%", 
					style : "aui-center",
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : "40%", 
					style : "aui-left",
				},
				{ 
					headerText : "단위", 
					dataField : "unit", 
					width : "15%", 
					style : "aui-center",
				},
				{ 
					headerText : "구성수량", 
					dataField : "qty", 
					width : "15%", 
					style : "aui-center",
				}
			];
			auiGridMiddle = AUIGrid.create("#auiGridMiddle", columnLayoutMiddle, gridProsMiddle);
			AUIGrid.setGridData(auiGridMiddle, []);
			$("#auiGridMiddle").resize();
		}
		
		function createBottomAUIGrid() {
			var gridProsBottom = {
					rowIdField : "machine_seq",
					showRowNumColumn: true
			};
			var columnLayoutBottom = [
				{ 
					dataField : "container_seq", 
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
					dataField : "machine_seq", 
					visible : false
				},
				{ 
					dataField : "car_date2", 
					visible : false
				},
				{ 
					dataField : "machine_qty", 
					visible : false,
				},
				{ 
					dataField : "container_change_flag", 
					visible : false,
				},
				{ 
					dataField : "opt_code", 
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
					headerText : "PART NO", 
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
					style : "aui-center aui-link",
					editRenderer : {
						type : "InputEditRenderer",
						auiGrid : "#auiGridBottom",
						validator : AUIGrid.commonValidator
					}
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
				{ 
					headerText : "비고", 
					dataField : "lc_remark", 
					style : "aui-left"
				},
			];
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayoutBottom, gridProsBottom);
			AUIGrid.setGridData(auiGridBottom, opener.parentBodyList);
			// 차대번호 클릭시 위의 form에 데이터 세팅
			
			AUIGrid.bind(auiGridBottom, "cellClick", function(event) {
				if(event.dataField == 'body_no') {
					console.log("event ????????????????????????????  ", event);
					
					// 선택한 컨테이너SEQ 저장해놓기 (컨테이너를 지울때 컨테이너상태를 바꾸기 위하여 사용)
					$M.setValue("origin_container_seq", event.item.container_seq);
					$M.setValue("orign_body_no", event.item.body_no);
					
					$M.goNextPageAjax(this_page + "/containerList/search/" + event.item.machine_lc_no , "", {method : 'GET'},
						function(result) {
				    		if(result.success) {
				    			var containerList = result.list;
				    			
				    			var center_org_name; // 컨테이너에 매핑된 센터명
				    			$("#container_seq option").remove();
				    			$("#container_seq").append(new Option('- 선택 -', ""));
				    			for (item in containerList) {
				    				// 센터명 가공 : 있으면 센터명 없으면 공백
				    				if (containerList[item].center_org_name == undefined) {
				    					center_org_name = "";
				    				} else {
				    					center_org_name = "(" + containerList[item].center_org_name + ")";
				    				}
				    				$("#container_seq").append(new Option(containerList[item].container_name + center_org_name, containerList[item].container_seq));
				    			}
							}
				    		$("#container_seq").val(event.item.container_seq).prop("selected", true);
				    		
				    		// 입고센터 확정일 경우 수정 불가
							if (event.item.center_confirm_yn == "Y") {
								var in_org_name;
			    				if (event.item.in_org_name == undefined) {
			    					in_org_name = "";
			    				} else {
			    					in_org_name = "(" + event.item.in_org_name + ")";
			    				}
			    				
								$("#container_seq option").remove();
		 						$("#container_seq").append(new Option(event.item.container_name + in_org_name, event.item.container_seq));
		 						$("#main_form :input").prop("disabled", true);
								$("#main_form :button[onclick='javascript:goSave();']").prop("disabled", false);
								$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
							} else {
								$("#main_form :input").prop("disabled", false);
							}
						}
					);			
					
					$M.setValue("center_confirm_yn", event.item.center_confirm_yn);
					$M.setValue("machine_seq", event.item.machine_seq);
					$M.setValue("machine_name", event.item.machine_name);
					$M.setValue("body_no", event.item.body_no);
					$M.setValue("engine_model_1", event.item.engine_model_1);
					$M.setValue("engine_model_2", event.item.engine_model_2);
					$M.setValue("engine_no_1", event.item.engine_no_1);
					$M.setValue("engine_no_2", event.item.engine_no_2);
					$M.setValue("opt_model_1", event.item.opt_model_1);
					$M.setValue("opt_model_2", event.item.opt_model_2);
					$M.setValue("opt_no_1", event.item.opt_no_1);
					$M.setValue("opt_no_2", event.item.opt_no_2);
					$M.setValue("lc_remark", event.item.lc_remark);
					$M.setValue("in_org_code", event.item.in_org_code);
					$M.setValue("in_org_name", event.item.in_org_name);
					$M.setValue("driver_name", event.item.driver_name);
					$M.setValue("driver_hp_no", event.item.driver_hp_no);
					$M.setValue("container_seq", event.item.container_seq);
					$M.setValue("container_name", event.item.container_name);
					$M.setValue("center_org_code", event.item.center_org_code);
					$M.setValue("center_org_name", event.item.center_org_name);
					$M.setValue("machine_lc_no", event.item.machine_lc_no);
					$M.setValue("machine_ship_no", event.item.machine_ship_no);
					$M.setValue("seq_no", event.item.seq_no);
					$M.setValue("unit_price", event.item.unit_price);
					$("#car_date2").text(event.item.car_date2);
					$("#driver_name").text(event.item.driver_name);
					$("#driver_hp_no").text($M.phoneFormat(event.item.driver_hp_no));
					
					var shipDt = event.item.ship_dt.replace(/-/gi, "");
					var portPlanDt = event.item.port_plan_dt.replace(/-/gi, "");
					
					$M.setValue("ship_dt", event.item.ship_dt);
					$M.setValue("port_plan_dt", event.item.port_plan_dt);
					
					$("#ship_dt").text(shipDt == "" ? "" : $M.dateFormat($M.toDate(shipDt), 'yyyy-MM-dd'));
					$("#port_plan_dt").text(portPlanDt == "" ? "" : $M.dateFormat($M.toDate(portPlanDt), 'yyyy-MM-dd'));
					
					var optCode = event.item.opt_code;
					var machinePlantSeq = event.item.machine_plant_seq;
					
					var param = {
						opt_code : optCode,
						machine_plant_seq : machinePlantSeq,
					}
					
					$M.goNextPageAjax(this_page + "/opt/detail" , $M.toGetParam(param) , {method : 'GET'},
						function(result) {
				    		if(result.success) {
// 				    			console.log("result : ", result);
					    		AUIGrid.setGridData(auiGridMiddle, result.optPartList);
							}
						}
					);
				}
			});
			$("#auiGridBottom").resize(); 
		};
		
		function fnClose() {
			window.close();
		}
		
		// 컨터이너명 클릭시 컨테이너 정보 세팅
		function goSearchContainerInfo() {
			var containerSeq = $M.getValue("container_seq");
			console.log("containerSeq : ", containerSeq);
			var param = {
					"container_seq" : $M.getValue("container_seq")
			}
			
			if (containerSeq != "") {
				$M.goNextPageAjax(this_page + "/search/containerInfo" , $M.toGetParam(param), {method : 'GET'},
					function(result) {
		    			console.log("result : ", result);
			    		if(result.success) {
							$("#ship_dt").text($M.dateFormat($M.toDate(result.map.ship_dt), 'yyyy-MM-dd'));
							$("#port_plan_dt").text($M.dateFormat($M.toDate(result.map.port_plan_dt), 'yyyy-MM-dd'));
							$("#car_date2").text(result.map.car_date2);
							$("#driver_name").text(result.map.driver_name);
							$("#driver_hp_no").text($M.phoneFormat(result.map.driver_hp_no));
							$M.setValue("container_name", result.map.container_name);
							$M.setValue("container_seq", result.map.container_seq);
							$M.setValue("in_org_code", result.map.center_org_code);
							$M.setValue("in_org_name", result.map.center_org_name);
							$M.setValue("driver_name", result.map.driver_name);
							$M.setValue("driver_hp_no", result.map.driver_hp_no);
							$M.setValue("center_org_name", result.map.center_org_name);
							$M.setValue("center_org_code", result.map.center_org_code);
							$M.setValue("ship_dt", result.map.ship_dt);
							$M.setValue("port_plan_dt", result.map.port_plan_dt);
						}
					}
				);			
			} else {
				// 컨테이너가 선택이 안됐을경우
				var originContainerSeq = $M.getValue("origin_container_seq");
				console.log("origin_container_seq : ", originContainerSeq);
				
				$("#ship_dt").empty();
				$("#port_plan_dt").empty();
				$("#car_date2").empty();
				$("#driver_name").empty();
				$("#driver_hp_no").empty();
				$M.setValue("container_name", "");
				$M.setValue("container_seq", null);
				$M.setValue("container_change_flag", "Y");
				$M.setValue("in_org_code", "");
				$M.setValue("in_org_name", "");
				$M.setValue("driver_name", "");
				$M.setValue("driver_hp_no", "");
				$M.setValue("center_org_name", "");				
				$M.setValue("center_org_code", "");				
				$M.setValue("ship_dt", "");
				$M.setValue("port_plan_dt", "");				
			}
		}
		
		// 추가버튼 - 차대번호등록내역에 추가
		function fnAddBodyNo() {
			if (qty == machineQty) {
				alert("선적 가능수량을 초과했습니다.");
				return false;
			}
			
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}			
			
			var bodyNo = $M.getValue("body_no");
			var flag = "Y";  // 차대번호 중복체크 변수
			
			console.log("bodyNo >> ", bodyNo);
			console.log("parentBodyNoList >> ", parentBodyNoList);
			
			// 차대번호 중복체크 후 그리드에 세팅
			var bottomGridData = AUIGrid.getGridData(auiGridBottom);
			for (var i = 0 ; i < parentBodyNoList.length; i++) {
				if (parentBodyNoList[i] == bodyNo) {
					flag = "N";
				}
			}
			
			for (var i = 0; i < bottomGridData.length; i++) {
				if (bottomGridData[i].body_no == bodyNo) {
					flag = "N";
				}
			}
			
// 			console.log("flag : ", flag);
			if (flag == "Y") {
				$M.goNextPageAjax(this_page + "/duplicate/check/" + bodyNo, "", {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			// 차대번호 중복이 없을경우
			    			if(confirm("추가하시겠습니까?") == false) {
								return false;
							}
							
							frm = $M.toValueForm(frm);
							console.log(frm);
							
							var item = new Object();
							item.machine_seq = "0";
							item.machine_plant_seq = $M.getValue("machine_plant_seq");
							item.machine_name = $M.getValue("machine_name");
							item.body_no = $M.getValue("body_no");
							item.engine_model_1 = $M.getValue("engine_model_1");
							item.engine_model_2 = $M.getValue("engine_model_2");
							item.engine_no_1 = $M.getValue("engine_no_1");
							item.engine_no_2 = $M.getValue("engine_no_2");
							item.opt_model_1 = $M.getValue("opt_model_1");
							item.opt_model_2 = $M.getValue("opt_model_2");
							item.opt_no_1 = $M.getValue("opt_no_1");
							item.opt_no_2 = $M.getValue("opt_no_2");
							item.ship_dt = $("#ship_dt").text();
							item.port_plan_dt = $("#port_plan_dt").text();
							item.car_date2 = $("#car_date2").text();
							item.machine_lc_no = $M.getValue("machine_lc_no");
							item.machine_ship_no = $M.getValue("machine_ship_no");
							item.container_seq = $M.getValue("container_seq");
							item.container_name = $M.getValue("container_name");
							item.driver_name = $M.getValue("driver_name");
							item.driver_hp_no = $M.getValue("driver_hp_no");
							item.in_org_code = $M.getValue("in_org_code");
							item.in_org_name = $M.getValue("in_org_name");
							item.center_org_name = $M.getValue("center_org_name");
							item.center_org_code = $M.getValue("center_org_code");
							item.lc_remark = $M.getValue("lc_remark");
							item.seq_no = $M.getValue("seq_no");
							item.opt_code = $M.getValue("s_opt_code");
							item.unit_price = $M.getValue("unit_price");
							// 선적수량 추가
							item.machine_qty = 1;
							
							// 차대번호등록내역 그리드에 add
				    		AUIGrid.addRow(auiGridBottom, item, 'last');
				    		
				    		// addRow 후 차대번호등록 form에 다음 모델 셋팅.
				    		fnNextMachineInfo();
						} else {
							return;
						}
					}
				);
			} else {
				alert("차대번호가 중복됩니다.");
			}
			
		}
		
		// 차대번호 수정(저장)
		function goChangeSave() {
			if ($M.getValue("machine_name") == "") {
				alert("변경할 모델을 선택해주세요");
				return false;
			}
			
			if ($M.getValue("center_confirm_yn") == "Y") {
				alert("입고완료된 내역은 수정이 불가능합니다.");
				return false;
			}

// 			if(confirm("변경내역을 저장하시겠습니까?") == false) {
// 				return false;
// 			}
			
// 			console.log($M.getValue("in_org_code"));
// 			console.log($M.getValue("center_org_code"));
			
// 			var machineSeq = $M.getValue("machine_seq"); // 선택한 장비의 machine_seq
// 			console.log($M.getValue("machine_seq"));
		
// 			var items = AUIGrid.getItemsByValue(auiGridBottom, "machine_seq", $M.getValue("machine_seq"));
// 			var rowIdField = AUIGrid.getProp(auiGridBottom, "rowIdField");
// 			var items2update = [];
// 			var item, obj;
// 			for (var i = 0; i < items.length; i++) {
// 				item = items[i];
// 				obj = {};
// 				obj[rowIdField] = item[rowIdField];
// 				obj["body_no"] = $M.getValue("body_no");
// 				obj["engine_no_1"] = $M.getValue("engine_no_1");
// 				obj["opt_model_1"] = $M.getValue("opt_model_1");
// 				obj["opt_no_1"] = $M.getValue("opt_no_1");
// 				obj["container_seq"] = $M.getValue("container_seq");
// 				obj["container_name"] = $M.getValue("container_name");
// 				obj["container_change_flag"] = $M.getValue("container_change_flag");
// // 				obj["ship_dt"] = $("#ship_dt").text();
// // 				obj["port_plan_dt"] = $("#port_plan_dt").text();
// 				obj["ship_dt"] = $M.getValue("ship_dt");
// 				obj["port_plan_dt"] = $M.getValue("port_plan_dt");
// 				obj["car_date2"] = $("#car_date2").text();
// 				obj["driver_name"] = $("#driver_name").text();
// 				obj["driver_hp_no"] = $("#driver_hp_no").text();
// 				obj["lc_remark"] = $M.getValue("lc_remark");
// 				obj["in_org_code"] = $M.getValue("in_org_code");
// 				obj["in_org_name"] = $M.getValue("in_org_name");
				
// 				items2update.push(obj);
// 			}
// 			AUIGrid.updateRowsById(auiGridBottom, items2update); 
			
// 			var machineSeq = $M.getValue("machine_seq"); // 선택한 장비의 machine_seq
// 			console.log($M.getValue("machine_seq"));
			
// 			$M.setValue("orign_body_no", $M.getValue("body_no"));
			var orignBodyNo = $M.getValue("orign_body_no");
			var bodyNo = $M.getValue("body_no");
			console.log("orignBodyNo : ", orignBodyNo);
			console.log("bodyNo : ", bodyNo);
			
			if (orignBodyNo != bodyNo) {
				// 차대번호 중복체크 후 그리드에 세팅
				$M.goNextPageAjax(this_page + "/duplicate/check/" + bodyNo, "", {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			// 차대번호 중복이 없을경우
			    			if(confirm("변경내역을 저장하시겠습니까?") == false) {
								return false;
							}
							
			    			var items = AUIGrid.getItemsByValue(auiGridBottom, "machine_seq", $M.getValue("machine_seq"));
			    			var rowIdField = AUIGrid.getProp(auiGridBottom, "rowIdField");
			    			var items2update = [];
			    			var item, obj;
			    			for (var i = 0; i < items.length; i++) {
			    				item = items[i];
			    				obj = {};
			    				obj[rowIdField] = item[rowIdField];
			    				obj["body_no"] = $M.getValue("body_no");
			    				obj["engine_model_1"] = $M.getValue("engine_model_1");
			    				obj["engine_model_2"] = $M.getValue("engine_model_2");
			    				obj["engine_no_1"] = $M.getValue("engine_no_1");
			    				obj["engine_no_2"] = $M.getValue("engine_no_2");
			    				obj["opt_model_1"] = $M.getValue("opt_model_1");
			    				obj["opt_model_2"] = $M.getValue("opt_model_2");
			    				obj["opt_no_1"] = $M.getValue("opt_no_1");
			    				obj["opt_no_2"] = $M.getValue("opt_no_2");
			    				obj["container_seq"] = $M.getValue("container_seq");
			    				obj["container_name"] = $M.getValue("container_name");
			    				obj["container_change_flag"] = $M.getValue("container_change_flag");
			    				obj["ship_dt"] = $M.getValue("ship_dt");
			    				obj["port_plan_dt"] = $M.getValue("port_plan_dt");
			    				obj["car_date2"] = $("#car_date2").text();
			    				obj["driver_name"] = $("#driver_name").text();
			    				obj["driver_hp_no"] = $("#driver_hp_no").text();
			    				obj["lc_remark"] = $M.getValue("lc_remark");
			    				obj["in_org_code"] = $M.getValue("in_org_code");
			    				obj["in_org_name"] = $M.getValue("in_org_name");
			    				obj["center_org_name"] = $M.getValue("center_org_name");
			    				obj["unit_price"] = $M.getValue("unit_price");

			    				items2update.push(obj);
			    			}
			    			AUIGrid.updateRowsById(auiGridBottom, items2update);
						} else {
							return;
						}
					}
				);
			} else {
				// 검사할필요없음.
				
				if(confirm("변경내역을 저장하시겠습니까?") == false) {
					return false;
				}				
				
				var machineSeq = $M.getValue("machine_seq"); // 선택한 장비의 machine_seq
				console.log($M.getValue("machine_seq"));
			
				var items = AUIGrid.getItemsByValue(auiGridBottom, "machine_seq", $M.getValue("machine_seq"));
				var rowIdField = AUIGrid.getProp(auiGridBottom, "rowIdField");
				var items2update = [];
				var item, obj;
				for (var i = 0; i < items.length; i++) {
					item = items[i];
					obj = {};
					obj[rowIdField] = item[rowIdField];
					obj["body_no"] = $M.getValue("body_no");
					obj["engine_model_1"] = $M.getValue("engine_model_1");
					obj["engine_model_2"] = $M.getValue("engine_model_2");
					obj["engine_no_1"] = $M.getValue("engine_no_1");
					obj["engine_no_2"] = $M.getValue("engine_no_2");
					obj["opt_model_1"] = $M.getValue("opt_model_1");
					obj["opt_model_2"] = $M.getValue("opt_model_2");
					obj["opt_no_1"] = $M.getValue("opt_no_1");
					obj["opt_no_2"] = $M.getValue("opt_no_2");
					obj["container_seq"] = $M.getValue("container_seq");
					obj["container_name"] = $M.getValue("container_name");
					obj["container_change_flag"] = $M.getValue("container_change_flag");
	// 				obj["ship_dt"] = $("#ship_dt").text();
	// 				obj["port_plan_dt"] = $("#port_plan_dt").text();
					obj["ship_dt"] = $M.getValue("ship_dt");
					obj["port_plan_dt"] = $M.getValue("port_plan_dt");
					obj["car_date2"] = $("#car_date2").text();
					obj["driver_name"] = $("#driver_name").text();
					obj["driver_hp_no"] = $("#driver_hp_no").text();
					obj["lc_remark"] = $M.getValue("lc_remark");
					obj["in_org_code"] = $M.getValue("in_org_code");
					obj["in_org_name"] = $M.getValue("in_org_name");
					obj["center_org_name"] = $M.getValue("center_org_name");
					obj["unit_price"] = $M.getValue("unit_price");

					items2update.push(obj);
				}
				alert("변경 내역이 저장되었습니다.");
				AUIGrid.updateRowsById(auiGridBottom, items2update); 				
			}
		}
		
		// 저장 : 부모페이지(장비대장관리-선적) 의 차대번호등록내역으로 list넘겨주기.
		function goSave() {
			if(confirm("변경내역을 저장하시겠습니까?") == false) {
				return false;
			}
			// 부모페이지로 넘겨줄 차대번호등록내역 그리드 데이터
			var gridData = AUIGrid.getGridData(auiGridBottom);
			console.log("차대번호등록내역 그리드 데이터 : ", gridData);

			var addRows = AUIGrid.getAddedRowItems(auiGridBottom);
			var editRows = AUIGrid.getEditedRowItems(auiGridBottom);
// 			console.log("추가된 내역 : ", addRows);
// 			console.log("변경된 내역 : ", editRows);
			
			alert("변경 내역이 저장되었습니다.");
			// 변경내역은 부모창의 차대번호등록내역 list에서 찾아서 updateRow 처리
			opener.fnSetMachineBodyList(addRows, editRows);
			fnClose();
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" name="machine_seq">
<input type="hidden" name="in_org_code">
<input type="hidden" name="in_org_name">
<input type="hidden" name="driver_name">
<input type="hidden" name="driver_hp_no">
<input type="hidden" name="center_org_name">
<input type="hidden" name="center_org_code">
<input type="hidden" name="machine_plant_seq">
<input type="hidden" name="machine_lc_no">
<input type="hidden" name="machine_ship_no">
<input type="hidden" name="container_name">
<input type="hidden" name="seq_no">
<input type="hidden" name="ship_dt">
<input type="hidden" name="port_plan_dt">
<input type="hidden" name="machine_qty">
<input type="hidden" name="center_confirm_yn">
<input type="hidden" name="container_change_flag">
<input type="hidden" name="origin_container_seq">
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
					<h4>차대번호등록</h4>			
				</div>		
			</div>	
<!-- 상단 폼테이블 -->	
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">장비모델</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-8">
										<input type="text" class="form-control" readonly id="machine_name" name="machine_name" value="">
									</div>
								</div>
							</td>			
							<th class="text-right essential-item">엔진모델1</th>
							<td>
								<input type="text" class="form-control rb" id="engine_model_1" name="engine_model_1" required="required" value="${map.motor_type}">
							</td>
							<th class="text-right">엔진모델2</th>
							<td>
								<input type="text" class="form-control" id="engine_model_2" name="engine_model_2" value="${map.motor_type_2}">
							</td>
							<th class="text-right">옵션모델1</th>
							<td>
								<input type="text" class="form-control" id="opt_model_1" name="opt_model_1" value="">
							</td>	
							<th class="text-right">옵션모델2</th>
							<td>
								<input type="text" class="form-control" id="opt_model_2" name="opt_model_2" value="">
							</td>				
						</tr>
						<tr>
							<th class="text-right essential-item">차대번호</th>
							<td>
								<input type="text" class="form-control rb" id="body_no" name="body_no" alt="차대번호"  required="required">
							</td>									
							<th class="text-right essential-item">엔진번호1</th>
							<td>
								<input type="text" class="form-control rb" id="engine_no_1" name="engine_no_1" alt="엔진번호1"  required="required">
							</td>	
							<th class="text-right">엔진번호2</th>
							<td>
								<input type="text" class="form-control" id="engine_no_2" name="engine_no_2">
							</td>	
							<th class="text-right">옵션번호1</th>
							<td>
								<input type="text" class="form-control" id="opt_no_1" name="opt_no_1">
							</td>	
							<th class="text-right">옵션번호2</th>
							<td>
								<input type="text" class="form-control" id="opt_no_2" name="opt_no_2">
							</td>
						</tr>
						<tr>
							<th class="text-right">발주수량</th>			
							<td id="qty"></td>	
							<th class="text-right">선적수량</th>
							<td id="machine_qty"></td>	
							<th class="text-right">L/C 상태</th>
							<td id="machine_lc_status_name"></td>	
							<th class="text-right">컨테이너명</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-9">
										<select class="form-control" id="container_seq" name="container_seq" onchange="javascript:goSearchContainerInfo();">
<!-- 											<option value="">- 선택 -</option> -->
										</select>
									</div>
								</div>
							</td>								
							<th class="text-right">선적일자</th>
							<td id="ship_dt"></td>		
						</tr>
						<tr>
							<th class="text-right">입항예정일</th>
							<td id="port_plan_dt"></td>		
							<th class="text-right">배차일시</th>
							<td id="car_date2"></td>	
							<th class="text-right">배차기사명</th>
							<td id="driver_name"></td>
							<th class="text-right">전화번호</th>
							<td id="driver_hp_no"></td>
							<th class="text-right">비고</th>
							<td>
								<input type="text" class="form-control" id="lc_remark" name="lc_remark">
							</td>
						</tr>
						<tr>
							<th class="text-right">외화단가</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-8">
										<input type="text" class="form-control text-right" readonly name="unit_price" id="unit_price" format="decimal" datatype="int">
									</div>
									<div class="col-3">원</div>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
			</div> 
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /상단 폼테이블 -->
<!-- 하단 폼테이블 -->		
<!-- 옵션품목 -->
			<div>
				<div class="title-wrap">
					<h4>옵션품목</h4>
				</div>
				<div id="auiGridMiddle" style="margin-top: 5px; height: 180px;"></div>
			</div>
<!-- /옵션품목 -->
<!-- 차대번호등록내역 -->
			<div>
				<div class="title-wrap mt10">
					<h4>차대번호등록내역</h4>
				</div>
				<div id="auiGridBottom" style="margin-top: 5px; height: 180px;"></div>
			</div>
<!-- /발주내역 -->
<!-- /하단 폼테이블 -->	
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