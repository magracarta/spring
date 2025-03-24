<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비생산발주 > null > 장비생산발주상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
 		// 상세내역 데이터
		var jsonList = ${jsonList}
		var apprStatus = jsonList[0].appr_proc_status_cd;
		var regMemNo = jsonList[0].reg_mem_no;
		var memNo = '${SecureUser.mem_no}';
		var auiGrid1;
		var totalCnt = jsonList.length;
		var rowIndex = 0;
		
		var editYn;

		var maxSeqNo = '${maxSeqNo}';

		var parentOrderText;

		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
			// 옵션품목 그리드 생성
			createGridOptionList();
			// 장비추가내역 그리드 total_cnt
			$("#total_cnt").html(totalCnt);
			
			// 작성중인데, 작성자면 수정 가능
			// 결재완료인데, 작성자, 조선왕, 신정애면 수정 가능.
			// 2021-10-15 (SR : 11449) 생산발주 결재완료 후 수정가능하도록 요청
			// 수정가능여부
			editYn = ((apprStatus == 01 && regMemNo != memNo) || (apprStatus == 05 && (memNo == regMemNo || memNo == 'MB00000481' || memNo == 'MB00000501') == false) || apprStatus == 03) == false ? 'Y' : 'N';
			if (editYn == 'N') {
				fnModifyControl();
			}
			
			// 결재상태에 따라 수정가능 제어
// 			if (apprStatus != 01 || regMemNo != memNo) {
// 				fnModifyControl();
// 			}

			if ("${list[0].order_file_seq}" != "" && "${list[0].order_file_seq}" != "0") {
				fnPrintFileOrder('${list[0].order_file_seq}', '${list[0].order_file_name}');
			}

			// 각 발주옵션 textarea 크기 세팅
			var seqNos = $("input[name=order_text_seq_no]");
			for (let i = 0; i < seqNos.length; i++) {
				setTextAreaHeight(seqNos.eq(i).val());
			}
		});
		
		// 결재상태에 따라 수정가능 제어
		function fnModifyControl() {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :button[onclick='javascript:goOrderPrint();']").prop("disabled", false);
// 			$("#main_form :button[onclick='javascript:fnAdd();']").prop("disabled", false);
// 			$("#main_form :button[onclick='javascript:goModelInfoClick();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goSearchOptDetail();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
			$("#opt_name").prop("disabled", false);
			$("#confirm_yn_y").prop("disabled", false);
			$("#confirm_yn_n").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goProcessConfirm();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goSaveMachineOrderText();']").prop("disabled", false);
			$("#main_form :button[name^='order_text_btn']").prop("disabled", false);

			$("#modify_btn").prop("disabled", false);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros1 = {
				// 푸터, 셀수정, 셀상태 기능 활성화
				showFooter : true,	
				footerPosition : "top",
				rowIdField : "_$uid",
				height : 130,
				editable : true,
				// showStateColumn : true
			};
			// 컬럼레이아웃
			var columnLayout1 = [
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
					headerText : "Part NO", 
					dataField : "machine_name", 
					width : "155",
					style : "aui-center aui-link",
					editable : true,
			        editRenderer : {
			           type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
			           conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
			              var param = {
			                     s_sale_yn : 'Y',
			                     s_machine_order_yn : 'Y',
			              };
			              return fnGetMachineSearchRenderer(dataField, param);
			           },
			        }
				},
				{ 
					headerText : "Q`ty", 
					dataField : "qty", 
					dataType : "numeric",
					width : "50",
					editable : true,
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (apprStatus == 03 || (apprStatus == 01 && regMemNo != memNo)
								|| (apprStatus == 05 && (memNo == regMemNo || memNo == 'MB00000481' || memNo == 'MB00000501') == false) 
							) {
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
					headerText : "U/Price", 
					dataField : "unit_price", 
					dataType : "numeric",
					formatString : "#,##0.00",
					width : "110",
					style : "aui-right",
					editable : true,
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (apprStatus == 03 || (apprStatus == 01 && regMemNo != memNo)
								|| (apprStatus == 05 && (memNo == regMemNo || memNo == 'MB00000481' || memNo == 'MB00000501') == false) 
							) {
							return null;
						} else {
							return "aui-editable";
						}
					},
					editRenderer : {
					      type : "InputEditRenderer",
					      min : 1,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "Amount", 
					dataField : "amount",
					width : "130",
					dataType : "numeric",
					formatString : "#,##0.00",
					style : "aui-right",
					editable : false,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						// 수량 * 단가 계산
						return ( item.qty * item.unit_price ); 
					}
				},
				{ 
					headerText : "메모", 
					dataField : "remark", 
					editable : true,
					style : "aui-left",
					width : "190",
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (apprStatus == 03 || (apprStatus == 01 && regMemNo != memNo)
								|| (apprStatus == 05 && (memNo == regMemNo || memNo == 'MB00000481' || memNo == 'MB00000501') == false) 
							) {
							return null;
						} else {
							return "aui-editable";
						}
					}
				},
				{
					headerText : "삭제", 
					dataField : "removeBtn",
					width : "60",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var newAddYn = AUIGrid.isAddedById(event.pid, event.item._$uid);
							// 결재상태에 따라 삭제기능 활성화/비활성화
							// 2021-10-15 (SR : 11449) 생산발주 결재완료 후 수정가능하도록 요청
							if (editYn == 'Y') {
								var isRemoved = AUIGrid.isRemovedById(auiGrid1, event.item._$uid);
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);
									AUIGrid.update(auiGrid1);
									totalCnt--;
									$("#total_cnt").html(totalCnt);
									$M.setValue("total_amt", AUIGrid.getFooterData(auiGrid1)[2].text);
									fnRemoveOrderText(event.item.seq_no, 'Y', newAddYn);
								} else {
									AUIGrid.restoreSoftRows(auiGrid1, "selectedIndex"); 
									AUIGrid.update(auiGrid1);
									totalCnt++;
									$("#total_cnt").html(totalCnt);
									$M.setValue("total_amt", AUIGrid.getFooterData(auiGrid1)[2].text);
									fnRemoveOrderText(event.item.seq_no, 'N', newAddYn);
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
				},
				{
					dataField : "order_text",
					visible : false
				},
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "machine_name"
				}, 
				{
					dataField : "qty",
					positionField : "qty",
					operation : "SUM",
					style : "aui-center aui-footer",
				},
				{
					dataField : "amount",
					positionField : "amount",
					formatString : "#,##0.00",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid1);
						var rowIdField = AUIGrid.getProp(auiGrid1, "rowIdField");
						var item;
						var sum = 0;
						for(var i=0, len=gridData.length; i<len; i++) {
							item = gridData[i];
							if(!AUIGrid.isRemovedById(auiGrid1, item[rowIdField])) {
								sum += item.amount;
							}
						}
// 						return Math.floor(sum);
						return sum;
					}
				}
			];
			
			// auiGrid1 에 그리드 생성
			auiGrid1 = AUIGrid.create("#auiGrid1", columnLayout1, gridPros1);
			// 푸터 세팅
			AUIGrid.setFooter(auiGrid1, footerColumnLayout);
			// 그리드 데이터 갱신
			AUIGrid.setGridData(auiGrid1, ${jsonList});
			// 추가행 에디팅 진입 허용
			AUIGrid.bind(auiGrid1, "cellEditBegin", function (event) {
				if (event.dataField == "machine_name") {
					// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
					if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						return false;
					}
				}
				
				// 2021-10-15 (SR : 11449) 생산발주 결재완료 후 작성자, 조선왕, 신정애면 수정 가능
				// 결재상태에 따라 에디팅 제어
				if (editYn == 'N') {
					if (event.dataField == "qty" || event.dataField == "unit_price" || event.dataField == "remark") {
						return false;
					}
				}
				
// 				if (apprStatus != 01 || regMemNo != memNo) {
// 					if (event.dataField == "qty" || event.dataField == "unit_price" || event.dataField == "remark") {
// 						return false;
// 					}
// 				}
				
			});
			AUIGrid.bind(auiGrid1, "cellEditEndBefore", auiCellEditHandler);
			AUIGrid.bind(auiGrid1, "cellEditEnd", auiCellEditHandler);
			AUIGrid.bind(auiGrid1, "cellEditCancel", auiCellEditHandler);
			$("#auiGrid1").resize();
		}
		
		function createGridOptionList() {
			var gridPros2 = {
				rowIdField : "row",
				height : 130
			};
			var columnLayout2 = [
				{
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "25%", 
					style : "aui-center"
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left"
				},
				{ 
					headerText : "단위", 
					dataField : "part_unit", 
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "구성수량", 
					dataField : "qty", 
					width : "15%", 
					style : "aui-center"
				}
			];
			
			auiGrid2 = AUIGrid.create("#auiGrid2", columnLayout2, gridPros2);
			// row행 클릭시 데이터 출력
			AUIGrid.bind(auiGrid1, "cellClick", function(event) {
				if (event.item.machine_plant_seq != "") {
					// 오른쪽그리드에 데이터 세팅.
					machinePlantSeq = event.item.machine_plant_seq;
					rowIndex = event.rowIndex;
					
					if(event.dataField == 'machine_name') {
						var param = {
							machine_plant_seq : event.item.machine_plant_seq,
							machine_order_no : event.item.machine_order_no,
							opt_code : event.item.opt_code,
							seq_no : event.item.seq_no
						};				
						
						$M.goNextPageAjax("/sale/sale020101/opt/search" , $M.toGetParam(param) , {method : 'GET'},
							function(result) {
					    		if(result.success) {
									// 옵션품목그리드에 데이터 세팅
									if (result.optList.length != 0) {
						    			$M.setValue("opt_name", result.optList[0].opt_code);
						    			$M.setValue("machine_plant_seq", event.item.machine_plant_seq);
									}
					    			// select box에 optList의 옵션명을 넣어줌
					    			$("#opt_name option").remove();
					    			var optList = result.optList;
					    			
					    			for (item in optList) {
					    				$("#opt_name").append(new Option(optList[item].opt_kor_name, optList[item].opt_code));
					    			}
				    				if (optList.length == 0) {
						    			$("#opt_name").append(new Option('- 선택 -', ""));
				    				} 
				    				
				    				if (result.map.opt_code != "") {
					    				$("#opt_name").val(result.map.opt_code).prop("selected", true);
				    				}
				    				
				    				if (result.optList.length != 0) {
										var optCode = result.map.opt_code == '' ? result.optList[0].opt_code : result.map.opt_code;
										goSearchOptDetail(optCode, event.rowIndex);
										// goSearchOptDetail(result.map.opt_code, event.rowIndex);
				    				} else {
				    					goSearchOptDetail();
				    				}
								}
							}
						);
					};				
				}
			});
			$("#auiGrid2").resize(); 
		}
		
		function auiCellEditHandler(event) {
			// 합계금액 폼에 세팅
			$M.setValue("total_amt", AUIGrid.getFooterData(auiGrid1)[2].text);
			
			switch(event.type) {
			case "cellEditEndBefore" :
				if(event.dataField == "machine_name") {
					var isUnique = AUIGrid.isUniqueValue(auiGrid1, event.dataField, event.value);	
					if (event.value == "") {
						return event.oldValue;							
					}
				}
				
			break;			
			
		    case "cellEditEnd" :
	         if(event.dataField == "machine_name") {
				if (event.value == ""){
					return "";
				}
	            var machineItem = fnGetMachineItem(event.value);
	            if(typeof machineItem === "undefined") {
	               return;
	            }
	            
	            machinePlantSeq = machineItem.machine_plant_seq;
	            
				$M.goNextPageAjax("/sale/sale020101/price/" + machinePlantSeq, "", {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			// 해당 장비의 가격이 없을때 입력받도록
			    			var sale_price = null;
			    			if (result.sale_price != "") {
				    			sale_price = result.sale_price;
			    			}
			    			
				            // 수정 완료하면, 나머지 필드도 같이 업데이트 함.
				            AUIGrid.updateRow(auiGrid1, {
				            	machine_name : machineItem.machine_name,
				            	maker_name : machineItem.maker_name,
				            	machine_type_name : machineItem.machine_type_name,
				            	machine_sub_type_name : machineItem.machine_sub_type_name,
				            	machine_sub_type_name : machineItem.machine_sub_type_name,
				            	sale_yn : machineItem.sale_yn,
				            	machine_plant_seq : machinePlantSeq,
				            	unit_price : sale_price
				            }, event.rowIndex);

							var orderText = machineItem.order_text;
							var seqNo = event.item.seq_no;
							fnSetOrderText(event.item.seq_no, machineItem.order_text, event.item.machine_name);

						}
					}
				);	
	         }
	         
	        // 에디팅 제어
	        fnEditControl();
	        
			var param = {
				machine_plant_seq : machinePlantSeq
			};	
	        
			if(undefined != param.machine_plant_seq && "" != param.machine_plant_seq) {
				$M.goNextPageAjax("/sale/sale020101/opt/search" , $M.toGetParam(param) , {method : 'GET'},
					function(result) {
			    		if(result.success) {
							// 옵션품목그리드에 데이터 세팅
							if (result.optList.length != 0) {
				    			$M.setValue("opt_name", result.optList[0].opt_code);
				    			$M.setValue("machine_plant_seq", machinePlantSeq);
							}
			    			// select box에 optList의 옵션명을 넣어줌
			    			$("#opt_name option").remove();
			    			var optList = result.optList;
			    			
			    			for (item in optList) {
			    				$("#opt_name").append(new Option(optList[item].opt_kor_name, optList[item].opt_code));
			    			}
		    				if (optList.length == 0) {
				    			$("#opt_name").append(new Option('- 선택 -', ""));
		    				}
		    				
		    				if (result.optList.length != 0) {
								goSearchOptDetail(result.optList[0].opt_code, event.rowIndex);
		    				} else {
		    					goSearchOptDetail();
		    				}
						}
					}
				);
			}
	        
	        // 에디팅이 완료된 후에만 옵션품목 조회가 가능하도록하는 작업.
			AUIGrid.bind(auiGrid1, "cellClick", function(event) {
				if (event.item.machine_plant_seq != "") {
					// 오른쪽그리드에 데이터 세팅.
					machinePlantSeq = event.item.machine_plant_seq;
					rowIndex = event.rowIndex;
					
					if(event.dataField == 'machine_name') {
						var param = {
							machine_plant_seq : machinePlantSeq,
						};				
						
						$M.goNextPageAjax("/sale/sale020101/opt/search" , $M.toGetParam(param) , {method : 'GET'},
							function(result) {
					    		if(result.success) {
									// 옵션품목그리드에 데이터 세팅
									if (result.optList.length != 0) {
						    			$M.setValue("opt_name", result.optList[0].opt_code);
						    			$M.setValue("machine_plant_seq", machinePlantSeq);
									}
					    			// select box에 optList의 옵션명을 넣어줌
					    			$("#opt_name option").remove();
					    			var optList = result.optList;
					    			
					    			for (item in optList) {
					    				$("#opt_name").append(new Option(optList[item].opt_kor_name, optList[item].opt_code));
					    			}
				    				if (optList.length == 0) {
						    			$("#opt_name").append(new Option('- 선택 -', ""));
				    				}
				    				
				    				if (result.optList.length != 0) {
										goSearchOptDetail(result.optList[0].opt_code, event.rowIndex);
				    				} else {
				    					goSearchOptDetail();
				    				}
								}
							}
						);
					};				
				}
			});
	         break;	
			}
		};		

		
	   // machine_name 으로 검색해온 정보 아이템 반환.
	   function fnGetMachineItem(machine_name) {
	      var item;
	      $.each(recentMachineList, function(n, v) {
	         if(v.machine_name == machine_name) {
	            item = v;
	            return false;
	         }
	      });
	      return item;
	   };
				
		
		function goOrderPrint() {
			openReportPanel('sale/sale0201p01_01_20240702.crf','machine_order_no=' + $M.getValue("machine_order_no"));
		}

		function goModify(isRequestAppr) {
			var msg = "수정하시겠습니까?"
			// 결재 요청
			if (isRequestAppr != undefined) {
				var orderFileSeq = $M.getValue("order_file_seq");
				if (orderFileSeq == '' || orderFileSeq == 0) {
					msg = "오더확인서 없이 결재를 상신하면 선적발주서 작성이 불가합니다.\n결재요청을 진행하시겠습니까?";
				} else {
					msg = "결재요청 하시겠습니까?";
				}
			}

			if (confirm(msg) == false) {
				return false;
			}

			var frm = document.main_form;
			
			if($M.validation(frm) == false) {
				return;
			}

			frm = $M.toValueForm(frm);
			
			// 장비추가내역 벨리데이션
			var data = AUIGrid.getGridData(auiGrid1);
			if (data.length == 0) {
				alert("장비를 추가해주세요.");
				return;
			}
			
			if(fnCheckGridEmpty1(auiGrid1) == false) {
				return;
			}
			
			var machineOrderNo = $M.getValue("machine_order_no");
			$M.setValue("save_mode", "modify");
			
			// 장비추가내역 그리드
			var gridForm = fnChangeGridDataToForm(auiGrid1);
			$M.copyForm(gridForm, frm);

			if (isRequestAppr != undefined) {
				$M.setValue("save_mode", "appr");
			}

			$M.goNextPageAjax(this_page + "/" + machineOrderNo + "/modify", gridForm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			if (isRequestAppr != undefined) {
			    			alert("처리가 완료되었습니다.");
		    			} else {
			    			alert("수정이 완료되었습니다.");
		    			}
		    			window.opener.location.reload();
		    			location.reload();
					}
				}
			);
		}
		
		// 상신취소
		function goApprCancel() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				appr_cancel_yn : "Y"
			};
			openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
		}
		
		function goApprovalResultCancel(result) {
			$M.goNextPageAjax('/session/check', '', {method : 'GET'},
					function(result) {
				    	if(result.success) {
				    		alert("결재취소가 완료됐습니다.");	
				    		location.reload();
						}
					}
				);
		}
		
		// 결재처리
		function goApproval() {
			if (confirm("결재하시겠습니까?") == false) {
				return false;
			}
			
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}"
			};

			if ("${apprBean.appr_proc_status_cd}" == "05") {
				param["appr_reject_only"] = "Y";
			}
			
			// $M.setValue("save_mode", "approval"); // 승인
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}
		
		// 결재처리 결과
		function goApprovalResult(result) {
			if(result.appr_status_cd == '03') {
				alert("반려가 완료되었습니다.");
				window.opener.location.reload();
				location.reload();
			} else {
				alert("결재처리가 완료되었습니다.");
				window.opener.location.reload();
				location.reload();
			}
		}
		
		function goRequestApproval() {
			goModify('requestAppr');
		}
		
		// 삭제
		function goRemove() {
			if (confirm("삭제하시겠습니까?") == false) {
				return false;
			}
			var machineOrderNo = $M.getValue("machine_order_no");
			
			var frm = $M.toValueForm(document.main_form);
			
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid1];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			
			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);
			
			$M.goNextPageAjax(this_page + "/" + machineOrderNo + "/remove" , gridFrm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리 되었습니다.");
		    			fnClose();
		    			window.opener.location.reload();
					}
				}
			);	
		}
		
		function fnClose() {
			window.close(); 
		}
		
		// 매입처 조회 팝업
		function fnSearchClientComm() {
			var param = {
				
			};
			openSearchClientPanel('setSearchClientInfo', 'wide', $M.toGetParam(param));
		}
		
		// 매입처 조회 팝업 클릭 후 리턴
		// TODO : 매입처명 풀네임으로 변경해야함.
	    function setSearchClientInfo(row) {
			$M.setValue("cust_name", row.cust_name);
			$M.setValue("client_cust_no", row.cust_no)
	    }		
		
		// 장비추가내역 그리드 벨리데이션
		function fnCheckGridEmpty1() {
			return AUIGrid.validateGridData(auiGrid1, ["machine_name", "qty", "unit_price", "amount"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 행추가
		function fnAdd() {
			// AUIGrid.extend.js 에 장비(모델)조회 만든 것 이용.
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid1, "machine_plant_seq");
			fnSetCellFocus(auiGrid1, colIndex, "machine_plant_seq");
			var item = new Object();
			if(fnCheckGridEmpty1(auiGrid1)) {
		    		item.machine_plant_seq = "",
		    		item.seq_no = $M.toNum(maxSeqNo) + 1,
		    		item.machine_name = "",
		    		item.qty = null,
		    		item.unit_price = null,
		    		item.amount = null,
		    		item.remark = "",
		    		item.order_text = "",
		    		AUIGrid.addRow(auiGrid1, item, 'last');
					totalCnt++;
					maxSeqNo = $M.toNum(maxSeqNo) + 1;
					$("#total_cnt").html(totalCnt);
			}			
		}
		
		
		// rowIndex 갱신안될경우 잘못된 row의 opt_code가 업데이트 되므로 rowIndex 넘기도록 수정함.
		function goSearchOptDetail(val, rowIdx) {
			var optCode = val;
			if (optCode != undefined) {
				var param = {
					opt_code : optCode,
					machine_plant_seq : $M.getValue("machine_plant_seq"),
					s_sort_key : "part_no",
					s_sort_method : "asc"
				}
				$M.goNextPageAjax("/sale/sale020101/opt/detail" , $M.toGetParam(param) , {method : 'GET'},
					function(result) {
			    		if(result.success) {
							console.log("result---->>  ", result);
			    			if (result.optDtlList.length != 0) {
				    			AUIGrid.setGridData(auiGrid2, result.optDtlList);
				    			AUIGrid.updateRow(auiGrid1, {"opt_code" : result.optDtlList[0].opt_code}, rowIdx);
			    			} else {
			    				AUIGrid.clearGridData(auiGrid2);
			    			}
						} 
					}
				);			
			} else {
				AUIGrid.clearGridData(auiGrid2);
				return;
			}
		}
		
		// 장비추가 (모델추가)
		function goModelInfoClick() {
			var param = {
// 				machineReadOnlyField : "s_maker_cd,s_machine_type_cd,s_sale_yn"
				s_machine_order_yn : "Y"
			};
			if(fnCheckGridEmpty1(auiGrid1)) {
				openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
			}
		}
		
		// 장비추가 팝업에서 받아온 값 세팅
		function fnSetModelInfo(row) {
			console.log("row : ", row);
			var machine_plant_seq = row.machine_plant_seq 
			
			$M.goNextPageAjax("/sale/sale020101/price/" + machine_plant_seq, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			// 해당 장비의 가격이 없을때 입력받도록
		    			var sale_price = null;
		    			if (result.sale_price != "") {
			    			sale_price = result.sale_price;
		    			}
		    			
						// 값 추가
						var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid1, "machine_plant_seq");
						fnSetCellFocus(auiGrid1, colIndex, "machine_plant_seq");
						var item = new Object();
						if(fnCheckGridEmpty1(auiGrid1)) {
								item.machine_plant_seq = row.machine_plant_seq,
								item.seq_no = $M.toNum(maxSeqNo) + 1;
								item.machine_name = row.machine_name,
					    		item.qty = null,
					    		item.unit_price = sale_price,
					    		item.amount = null,
					    		item.remark = "",
					    		item.opt_code = "",
					    		item.order_text = "",
					    		AUIGrid.addRow(auiGrid1, item, 'last');
								totalCnt++;
								maxSeqNo = $M.toNum(maxSeqNo) + 1;
								$("#total_cnt").html(totalCnt);
						}

						fnSetOrderText(item.seq_no, row.order_text, row.machine_name);
					}
				}
			);
			
			// 중복 소스 제거
// 			var param = {
// 					machine_plant_seq : machine_plant_seq
// 				};
				
// 			$M.goNextPageAjax("/sale/sale020101/opt/search" , $M.toGetParam(param) , {method : 'GET'},
// 				function(result) {
// 		    		if(result.success) {
// 						// 옵션품목그리드에 데이터 세팅
// 						if (result.optList.length != 0) {
// 			    			$M.setValue("opt_name", result.optList[0].opt_code);
// 			    			$M.setValue("machine_plant_seq", machine_plant_seq);
// 						}
// 		    			// select box에 optList의 옵션명을 넣어줌
// 		    			$("#opt_name option").remove();
// 		    			var optList = result.optList;
		    			
// 		    			for (item in optList) {
// 		    				$("#opt_name").append(new Option(optList[item].opt_kor_name, optList[item].opt_code));
// 		    			}
// 	    				if (optList.length == 0) {
// 			    			$("#opt_name").append(new Option('- 선택 -', ""));
// 	    				}
	    				
// 	    				if (result.optList.length != 0) {
// 							goSearchOptDetail(result.optList[0].opt_code);
// 	    				} else {
// 	    					goSearchOptDetail();
// 	    				}
// 					}
// 				}
// 			);
			
			// 에디팅 제어
			fnEditControl();		
	         
	        // 에디팅이 완료된 후에만 옵션품목 조회가 가능하도록하는 작업.
			AUIGrid.bind(auiGrid1, "cellClick", function(event) {
				if (event.item.machine_plant_seq != "") {
					// 오른쪽그리드에 데이터 세팅.
					machinePlantSeq = event.item.machine_plant_seq;
					rowIndex = event.rowIndex;
					
					if(event.dataField == 'machine_name') {
						var param = {
							machine_plant_seq : event.item.machine_plant_seq,
						};				
						
						$M.goNextPageAjax("/sale/sale020101/opt/search" , $M.toGetParam(param) , {method : 'GET'},
							function(result) {
					    		if(result.success) {
									// 옵션품목그리드에 데이터 세팅
									if (result.optList.length != 0) {
						    			$M.setValue("opt_name", result.optList[0].opt_code);
						    			$M.setValue("machine_plant_seq", event.item.machine_plant_seq);
									}
					    			// select box에 optList의 옵션명을 넣어줌
					    			$("#opt_name option").remove();
					    			var optList = result.optList;
					    			
					    			for (item in optList) {
					    				$("#opt_name").append(new Option(optList[item].opt_kor_name, optList[item].opt_code));
					    			}
				    				if (optList.length == 0) {
						    			$("#opt_name").append(new Option('- 선택 -', ""));
				    				}
				    				
				    				if (result.optList.length != 0) {
										goSearchOptDetail(result.optList[0].opt_code, event.rowIndex);
				    				} else {
				    					goSearchOptDetail();
				    				}
								}
							}
						);
					};				
				}
			});	         
			
		}
		
		
        // 에디팅이 끝난후에는 에디팅을 못하도록 막는 작업.
		function fnEditControl() {
		  AUIGrid.bind(auiGrid1, ["cellEditBegin"], function(event) {
		 	 if(event.dataField == "machine_name") {
		 		 if (event.item.machine_plant_seq == "") {
			    	 return true; 
		 		 } else {
		 			 return false;  // false 반환. 기본 행위인 편집 불가
		 		 }
		  	 }
		  });	
		}
        
        // 확정여부 저장
        function goProcessConfirm() {
			if (confirm("저장 하시겠습니까?") == false) {
				return false;
			}
        	
        	var param = {
        			"machine_order_no" : $M.getValue("machine_order_no"),
        			"confirm_yn" : $M.getValue("confirm_yn")
        	}
        	
    		$M.goNextPageAjax(this_page + "/modify/confirm", $M.toGetParam(param), {method : 'POST'},
   				function(result) {
   					if(result.success) {
   						alert("처리가 완료되었습니다.");
		    			window.opener.location.reload();
		    			location.reload();
   					}
   				}
   			);
        }
        
        // 결재여부와 상관없이 수정가능
        function goModify2() {
        	goModify();
        }

		// 파일찾기 팝업
		function goOrderFileUploadPopup() {
			var param = {
				upload_type	: "MACHINE",
				file_type : "both",
			};
			openFileUploadPanel('fnSetFileOrder', $M.toGetParam(param));
		}

		function fnSetFileOrder(file) {
			fnPrintFileOrder(file.file_seq, file.file_name);
		}

		// 팝업창에서 받아온 값
		function fnPrintFileOrder(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item submit_order">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="order_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFileOrder()"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.submit_div_order').append(str);
			$("#btn_submit_order_file").remove();
		}

		// 첨부파일 삭제
		function fnRemoveFileOrder() {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".submit_order").remove();
				var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goOrderFileUploadPopup()" id="btn_submit_order_file">파일찾기</button>'
				$('.submit_div_order').append(str);
				$M.setValue("order_file_seq", "0");
			} else {
				return false;
			}
		}

		// 발주옵션 저장
		function goSaveMachineOrderText() {
			// 추가된 행 아이템들(배열)
			var addLength = AUIGrid.getAddedRowItems(auiGrid1).length;
			// 삭제된 행 아이템들(배열)
			var removeLength = AUIGrid.getRemovedItems(auiGrid1).length;

			if (addLength > 0) {
				alert("추가된 장비가 있습니다.\n하단의 전체 수정을통해 진행해주세요.");
				return;
			}

			if (removeLength > 0) {
				alert("삭제된 장비가 있습니다.\n하단의 전체 수정을통해 진행해주세요.");
				return;
			}

			if (confirm("발주 옵션을 저장 하시겠습니까?") == false) {
				return false;
			}

			var orderTextSeqNoArr = [];
			$("[name=order_text_seq_no]").each(function() {
				orderTextSeqNoArr.push($(this).val());
			});

			var orderTextArr = [];
			for (var i = 0; i < orderTextSeqNoArr.length; i++) {
				var seqNo = orderTextSeqNoArr[i];

				$("[name=order_text_"+ seqNo +"]").each(function() {
					orderTextArr.push($(this).text());
				});
			}

			var option = {
				isEmpty : true
			};

			var param = {
				"machine_order_no" : $M.getValue("machine_order_no"),
				"order_text_seq_no_str" : $M.getArrStr(orderTextSeqNoArr, option),
				"order_text_str" : $M.getArrStr(orderTextArr, option)
			}

			$M.goNextPageAjax(this_page + "/save/order_text", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
						location.reload();
					}
				}
			);
		}

		// 발주옵션 내용 수정
		function goOrderTextModify(seqNo) {
			var orderText = $("#order_text_" + seqNo).text();
			parentOrderText = orderText;

			var removeYn = $M.getValue("remove_order_text_" + seqNo);
			if (removeYn == 'Y') {
				alert("삭제된 행은 편집 불가합니다.");
			} else {
				var popupOption = "";
				var param = {
					"seq_no" : seqNo,
				};
				$M.goNextPage('/sale/sale0201p03', $M.toGetParam(param), {popupStatus : popupOption});
			}
		}

		// 발주옵션 편집내용
		function fnOrderTextApply(param) {
			// 발주옵션 내용 셋팅
			$("#order_text_" + param.seq_no).html(param.order_text);

			setTextAreaHeight(param.seq_no);

			// 그리드 해당 row에 발주옵션 내용(hide) 셋팅
			var gridData = AUIGrid.getGridData(auiGrid1);
			var rowIdx = "";
			for (var i = 0; i < gridData.length; i++) {
				if (param.seq_no == gridData[i].seq_no) {
					rowIdx = AUIGrid.getRowIndexesByValue(auiGrid1, "_$uid", gridData[i]._$uid);
				}
			}

			AUIGrid.updateRow(auiGrid1, {"order_text" : param.order_text}, rowIdx);
		}

		function fnSetOrderText(seqNo, orderText, machineName) {
			var div = "";
			div += '<div class="option-item" id="order_text_div_'+ seqNo +'">';
			div += '	<div class="title-wrap">';
			div += '		<span class="title" id="order_text_machine_name_'+ seqNo +'" style="font-weight: bold;">' + machineName + '</span>';
			div += '		<button class="btn btn-default" id="order_text_btn" name="order_text_btn" onclick="javascript:goOrderTextModify(' + seqNo + ');">편집</button>';
			div += '	</div>';
			div += '	<input type="hidden" id="order_text_seq_no" name="order_text_seq_no" value="'+ seqNo +'">';
			div += '	<textarea id="order_text_'+ seqNo +'" name="order_text_'+ seqNo +'" readonly>'+ orderText +'</textarea>';
			div += '</div>';

			$("#order_text_div").append(div);

			var param = {
				"seq_no" : seqNo,
				"order_text" : orderText
			}
			fnOrderTextApply(param);
		}

		function fnRemoveOrderText(seqNo, realRemoveYn, newAddYn) {
			if (newAddYn) {
				// DB에 저장되지 않은 row는 바로 삭제
				$("#order_text_div_" + seqNo).remove();
			} else {
				// DB에 저장된 row는 줄긋기 (수정시삭제처리)
				if (realRemoveYn == 'Y') {
					// 삭제
					$("#order_text_" + seqNo).css({'text-decoration' : 'line-through'});
					$("#order_text_machine_name_" + seqNo).css({'text-decoration' : 'line-through'});
					$M.setValue("remove_order_text_" + seqNo, "Y");
				} else {
					// 삭제 취소
					$("#order_text_" + seqNo).css({'text-decoration' : ''});
					$("#order_text_machine_name_" + seqNo).css({'text-decoration' : ''});
					$M.setValue("remove_order_text_" + seqNo, "N");
				}
			}
		}

		/**
		 * 발주옵션의 textarea의 height를 텍스트 크기에 따라서 세팅
		 * @param {number} seqNo
		 */
		function setTextAreaHeight(seqNo) {
			const textarea = document.getElementById('order_text_' + seqNo);
			textarea.style.height = "auto";
			textarea.style.height = (textarea.scrollHeight + 2) + "px"; // 스크롤 없애기 위한 2px
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="save_mode" name="save_mode">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${list[0].appr_job_seq}">
<input type="hidden" name="reg_mem_no">
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
					<h4>장비생산발주상세</h4>
					<div >
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>		
					</div>					
				</div>
<!-- 결재영역 -->
				<div style="width: 41.2%; margin-left: 10px;">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->			
			</div>	
<!-- 상단 폼테이블 -->	
			<div>
				<table class="table-border mt10">
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
							<th class="text-right essential-item">발주번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-4">
<%-- 										<input type="hidden" name="machine_order_no" value="${list[0].machine_order_no}"> --%>
										<input type="text" class="form-control width100px" readonly id="machine_order_no" name="machine_order_no" value="${list[0].machine_order_no}">
									</div>
								 	/ 작성일자 : ${inputParam.reg_dt}
								</div>
							</td>
							<th class="text-right essential-item">담당자</th>
							<td>
								<input type="text" class="form-control width80px" id="reg_mem_name" name="reg_mem_name" value="${list[0].reg_mem_name}" readonly alt="담당자"  required="required">
								<input type="hidden" name="reg_id" id="reg_id" value="${list[0].reg.mem_no}" >
							</td>
							<th class="text-right">상태</th>
							<td>
								${list[0].appr_proc_status_name}
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">To</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control width140px" id="cust_name" name="cust_name" readonly alt="To"  required="required" value="${list[0].cust_name}">
									<input type="hidden" id="client_cust_no" name="client_cust_no" value="${list[0].client_cust_no}">
									<button type="button" class="btn btn-icon btn-primary-gra" id="client_btn" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th rowspan="2" class="text-right essential-item">From</th>
							<td rowspan="2">
								<div class="form-row inline-pd mb7">
									<div class="col-12">
										<input type="text" class="form-control rb" maxlength="40" id="mem_eng_name" name="mem_eng_name" alt="From"  required="required" value="${list[0].mem_eng_name}">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="30" id="job_eng_name" name="job_eng_name" value="${list[0].job_eng_name}">
									</div>
								</div>
							</td>
							<th rowspan="5" class="text-right essential-item">Remark</th>
							<td rowspan="5">
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control rb" maxlength="100" id="remark_1" name="remark_1" alt="Remark"  required="required" value="${list[0].remark_1}">
									</div>
								</div>
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_2" name="remark_2" value="${list[0].remark_2}">
									</div>
								</div>
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_3" name="remark_3" value="${list[0].remark_3}">
									</div>
								</div>
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_4" name="remark_4" value="${list[0].remark_4}">
									</div>
								</div>
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_5" name="remark_5" value="${list[0].remark_5}">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_6" name="remark_6" value="${list[0].remark_6}">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">Attn</th>
							<td>
								<input type="text" class="form-control rb" maxlength="40" id="client_charge_name" name="client_charge_name" alt="Attn"  required="required" value="${list[0].client_charge_name}">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">CC</th>
							<td>
								<input type="text" class="form-control rb" maxlength="40" id="client_rep_name" name="client_rep_name" alt="CC"  required="required" value="${list[0].client_rep_name}">
							</td>
							<th class="text-right essential-item">RE</th>
							<td>
								<input type="text" class="form-control rb" maxlength="60" id="order_remark" name="order_remark" alt="RE"  required="required" value="${list[0].order_remark}">
							</td>
						</tr>
						<tr>
							<th class="text-right">합계금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control text-right" readonly name="total_amt" id="total_amt" format="decimal" alt="합계금액"  required="required" value="${list[0].total_amt}">
									</div>
									<div class="col-3">원</div>
								</div>
							</td>
							<th class="text-right essential-item">화폐단위</th>
							<td>
								<select class="form-control width100px rb" id="money_unit_cd" name="money_unit_cd" required="required" alt="화폐단위">
									<c:forEach items="${codeMap['MONEY_UNIT']}" var="item">
										<option value="${item.code_value}" ${item.code_value == list[0].money_unit_cd ? 'selected' : '' }>${item.code_value}</option>
									</c:forEach>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">생산완료월</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<select class="form-control rb" id="s_start_year" name="s_start_year">
											<c:forEach var="i" begin="${inputParam.s_start_dt - 1}" end="${inputParam.s_start_dt + 2}" step="1">
												<option value="${i}" <c:if test="${i==inputParam.order_year}">selected</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</div>
									<div class="col-2">
										<select class="form-control rb" id="s_start_mon" name="s_start_mon">
											<c:forEach var="i" begin="1" end="12" step="1">
												<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.order_mon}">selected</c:if>>${i}월</option>
											</c:forEach>
										</select>
									</div>			
								</div>							
<!-- 								<div class="input-group"> -->
<%-- 									<input type="text" class="form-control rb border-right-0 width80px calDate" id="order_dt" name="order_dt" dateformat="yyyy-MM-dd" alt="발주일자" value="${list[0].order_dt}" alt="발주일자"  required="required"> --%>
<!-- 								</div> -->
							</td>
							<th class="text-right">확정여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="confirm_yn_y" name="confirm_yn" value="Y" ${list[0].confirm_yn == 'Y' ? 'checked="checked"' : ''} >
									<label class="form-check-label" for="confirm_yn_y">확정</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="confirm_yn_n" name="confirm_yn" value="N" ${list[0].confirm_yn == 'N' ? 'checked="checked"' : ''} >
									<label class="form-check-label" for="confirm_yn_n">미확정</label>
									&nbsp;&nbsp;&nbsp;&nbsp;<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">참고</th>
							<td colspan="3">
								<input type="text" class="form-control" maxlength="80" id="desc_text" name="desc_text" value="${list[0].desc_text}">
							</td>
							<th class="text-right">오더확인서 첨부</th>
							<td colspan="1">
								<div class="table-attfile submit_div_order">
								<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goOrderFileUploadPopup()" id="btn_submit_order_file">파일찾기</button>
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
				<div class="col-7">
<!-- 장비추가내역 -->
					<div class="title-wrap mt10">
						<h4>장비추가내역</h4>
						<div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							<button type="button" class="btn btn-default" onclick="javascript:goModelInfoClick();"><i class="material-iconsadd text-default"></i> 장비추가</button>
						</div>
					</div>
					<div id="auiGrid1" style="margin-top: 5px; height: 250px;">
					</div>
<!-- /장비추가내역 -->

					<!-- 옵션품목 -->
					<div class="title-wrap mt10">
						<h4>옵션품목</h4>
						<div>
							<select class="form-control" id="opt_name" name="opt_name" onchange="javascript:goSearchOptDetail(this.value);">
								<option>- 선택 -</option>
							</select>
						</div>
					</div>
					<div id="auiGrid2" style="margin-top: 5px; height: 100px;">
					</div>
					<!-- /옵션품목 -->

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>						
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
<!-- /좌측 폼테이블 -->
<!-- 우측 폼테이블 -->
				<div class="col-5">

					<!-- 발주옵션 -->
					<div class="title-wrap mt10">
						<h4>발주옵션</h4>
						<div>
							<button type="button" class="btn btn-important" style="width: 80px;" onclick="javascript:goSaveMachineOrderText();">발주옵션 저장</button>
						</div>
					</div>
					<div class="option-group" style="height: 250px;" id="order_text_div">
						<c:forEach var="item" items="${orderOptionList}">
							<div class="option-item" id="order_text_div_${item.seq_no}">
								<div class="title-wrap">
									<span class="title" id="order_text_machine_name_${item.seq_no}" style="font-weight: bold;">${item.machine_name}</span>
									<button class="btn btn-default" id="order_text_btn" name="order_text_btn" onclick="javascript:goOrderTextModify('${item.seq_no}');">편집</button>
								</div>
								<input type="hidden" id="order_text_seq_no" name="order_text_seq_no" value="${item.seq_no}">
								<textarea id="order_text_${item.seq_no}" name="order_text_${item.seq_no}" readonly>${item.order_text}</textarea>
							</div>
						</c:forEach>
					</div>
					<!-- /옵션품목 -->
<!-- 결재자의견-->						
					<div>
						<div class="title-wrap mt10">
							<h4>결재자의견</h4>									
						</div>
						<div class="fixed-table-container" style="width: 100%; height: 115px;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
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
					</div>
<!-- /결재자의견-->
				</div>
<!-- /우측 폼테이블 -->
			</div>
<!-- /하단 폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">						
					<div class="right">
						<!-- 작성중이아닐때, 수정가능하도록. (작성자, 조선왕, 신정애) -->
						<c:if test="${list[0].appr_proc_status_cd eq '05' and (list[0].reg_mem_no eq SecureUser.mem_no or page.fnc.F00151_001 eq 'Y')}">
							<button type="button" class="btn btn-info" id="modify_btn" name="modify_btn" style="width: 50px;" onclick="javascript:goModify2();">수정</button>
						</c:if>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
							<jsp:param name="pos" value="BOM_R"/>
							<jsp:param name="mem_no" value="${list[0].reg_mem_no}"/>
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