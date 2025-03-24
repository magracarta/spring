<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비생산발주 > 장비생산발주등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var totalCnt = 0;	
		var rowIndex = 0;

		var seqNo = 1;
		var parentOrderText;
		
		$(document).ready(function() {
			// 장비추가 내역 그리드 생성
			createAUIGrid();
			// 옵션품목 그리드 생성
			createGridOptionList();		
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros1 = {
				// 푸터, 셀수정, 셀상태 기능 활성화
				showFooter : true,
				footerPosition : "top",
				rowIdField : "_$uid",
				height : 130,
				editable : true,
				showStateColumn : true
			};
			// 컬럼레이아웃
			var columnLayout1 = [
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "opt_code", 
					visible : false
				},
				{ 
					headerText : "Part NO", 
					dataField : "machine_name", 
					width : "13%", 
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
					width : "7%", 
					style : "aui-center aui-editable",
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
					width : "15%",
					style : "aui-right aui-editable",
					editRenderer : {
					      type : "InputEditRenderer",
					      min : 1,
// 					      onlyNumeric : true,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "Amount", 
					dataField : "amount", 
					width : "20%", 
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
					style : "aui-left aui-editable"
				},
				{
					headerText : "삭제", 
					dataField : "removeBtn",
					width : "8%", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid1, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGrid1);
								totalCnt--;
								$("#total_cnt").html(totalCnt);
								$M.setValue("total_amt", AUIGrid.getFooterData(auiGrid1)[2].text);
							} else {
								AUIGrid.restoreSoftRows(auiGrid1, "selectedIndex"); 
								AUIGrid.update(auiGrid1);
								totalCnt++;
								$("#total_cnt").html(totalCnt);
								$M.setValue("total_amt", AUIGrid.getFooterData(auiGrid1)[2].text);
							};
							fnRemoveOrderText(event.item.seq_no);
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
					dataField : "mch_cost_price_seq",
					visible : false
				},
				{
					dataField : "order_text",
					visible : false
				},
				{
					dataField : "seq_no",
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
					operation : "SUM",
					formatString : "#,##0.00",
					style : "aui-right aui-footer"
				}
			];
			
			// auiGrid1 에 그리드 생성
			auiGrid1 = AUIGrid.create("#auiGrid1", columnLayout1, gridPros1);
			// 푸터 세팅
			AUIGrid.setFooter(auiGrid1, footerColumnLayout);
			// 그리드 데이터 갱신
			AUIGrid.setGridData(auiGrid1, []);
			AUIGrid.bind(auiGrid1, "cellEditEndBefore", auiCellEditHandler);
			AUIGrid.bind(auiGrid1, "cellEditEnd", auiCellEditHandler);
			AUIGrid.bind(auiGrid1, "cellEditCancel", auiCellEditHandler);
			$("#auiGrid1").resize();
			
		}
		
		function createGridOptionList() {
			var gridPros2 = {
				rowIdField : "row",
				editable : true,
				height : 130
			};
			var columnLayout2 = [
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "machine_order_no", 
					visible : false
				},
				{
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "30%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : "50%", 
					style : "aui-left",
					editable : false
				},
				{ 
					headerText : "단위", 
					dataField : "unit", 
					width : "10%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "구성수량", 
					dataField : "qty", 
					width : "10%", 
					style : "aui-center",
					editable : false
				}
			];
			auiGrid2 = AUIGrid.create("#auiGrid2", columnLayout2, gridPros2);
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
	            console.log("machineItem : ", machineItem);
	            if(typeof machineItem === "undefined") {
	               return;
	            }
	            
	            machinePlantSeq = machineItem.machine_plant_seq;
	            
				$M.goNextPageAjax(this_page + "/price/" + machinePlantSeq, "", {method : 'GET'},
					function(result) {
			    		if(result.success) {
	 		    			console.log(result);
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
				            	unit_price : sale_price,
								mch_cost_price_seq : machineItem.mch_cost_price_seq,
								order_text : machineItem.order_text,
								seq_no : seqNo
				            }, event.rowIndex);
							fnSetOrderText(seqNo, machineItem.order_text, machineItem.machine_name);
							seqNo = seqNo + 1;
						}
					}
				);	
	         }
	         
	        // 에디팅 제어
	        fnEditControl();
	        
	     // to do
			var param = {
				machine_plant_seq : machinePlantSeq
			};
			
			$M.goNextPageAjax(this_page + "/opt/search" , $M.toGetParam(param) , {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			console.log("result : ", result);
						// 옵션품목그리드에 데이터 세팅
						if (result.optList.length != 0) {
			    			$M.setValue("opt_name", result.optList[0].opt_code);
//				    			$M.setValue("machine_plant_seq", event.item.machine_plant_seq);
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
	    				
	    				rowIndex = totalCnt -1;
	    				
	    				if (result.optList.length != 0) {
							goSearchOptDetail(result.optList[0].opt_code, event.rowIndex);
	    				} else {
	    					goSearchOptDetail();
	    				}
					}
				}
			);	        
	         
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
						
						$M.goNextPageAjax(this_page + "/opt/search" , $M.toGetParam(param) , {method : 'GET'},
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
	         break;	
			}
		};
		
		// rowIndex 갱신안될경우 잘못된 row의 opt_code가 업데이트 되므로 rowIndex 넘기도록 수정함.
		function goSearchOptDetail(val, rowIdx) {
			var optCode = val;
			console.log("optCode ? ", optCode);			
			
			if (optCode != undefined) {
				var param = {
					opt_code : optCode,
					machine_plant_seq : $M.getValue("machine_plant_seq"),
					s_sort_key : "part_no",
					s_sort_method : "asc"
				}
				$M.goNextPageAjax(this_page + "/opt/detail" , $M.toGetParam(param) , {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			console.log("goSearchOptDetail 상세 결과 : ", result);
			    			
			    			if (result.optDtlList.length != 0) {
					    		AUIGrid.setGridData(auiGrid2, result.optDtlList);
					    		
								console.log("goSearchOptDetail 실행 rowIndex :: ", rowIndex);
// 					    		AUIGrid.updateRow(auiGrid1, {"opt_code" : result.optDtlList[0].opt_code}, rowIndex);
					    		AUIGrid.updateRow(auiGrid1, {"opt_code" : result.optDtlList[0].opt_code}, rowIdx);
			    			} else {
								AUIGrid.clearGridData(auiGrid2);
			    			}
						}
					}
				);
			} else {
// 				alert("해당 장비의 옵션이 없습니다.");
				AUIGrid.clearGridData(auiGrid2);
				return;
			}
			
		}
		
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
		
		// 매입처 조회 팝업
		function fnSearchClientComm() {
			var param = {};
			openSearchClientPanel('setSearchClientInfo', 'wide', $M.toGetParam(param));
		}
		
		// 매입처 조회 팝업 클릭 후 리턴
	    function setSearchClientInfo(row) {
			$M.setValue("cust_name", row.cust_name);
			$M.setValue("client_cust_no", row.cust_no);
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
			var machine_plant_seq = row.machine_plant_seq 
			
			$M.goNextPageAjax(this_page + "/price/" + machine_plant_seq, "", {method : 'GET'},
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
								item.machine_name = row.machine_name,
					    		item.qty = null,
					    		item.unit_price = sale_price,
					    		item.amount = null,
					    		item.remark = "",
					    		item.opt_code = "",
								item.order_text = "",
								item.seq_no = seqNo,
					    		AUIGrid.addRow(auiGrid1, item, 'last');
								totalCnt++;
								$("#total_cnt").html(totalCnt);
						}
						fnSetOrderText(seqNo, row.order_text, row.machine_name);
						seqNo = seqNo + 1;
					}
				}
			);
			
			// 에디팅 제어
			fnEditControl();		
			
			AUIGrid.bind(auiGrid1, "cellClick", function(event) {
				if (event.item.machine_plant_seq != "") {
					// 오른쪽그리드에 데이터 세팅.
					machinePlantSeq = event.item.machine_plant_seq;
					rowIndex = event.rowIndex;
					
					if(event.dataField == 'machine_name') {
						var param = {
							machine_plant_seq : event.item.machine_plant_seq,
						};				
						
						$M.goNextPageAjax(this_page + "/opt/search" , $M.toGetParam(param) , {method : 'GET'},
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
		    		item.machine_name = "",
		    		item.qty = null,
		    		item.unit_price = null,
		    		item.amount = null,
		    		item.remark = "",
		    		item.opt_code = "",
					item.order_text = "",
					// item.seq_no = seqNo,
		    		AUIGrid.addRow(auiGrid1, item, 'last');
					totalCnt++;
					$("#total_cnt").html(totalCnt);
			}
			// fnSetOrderText(seqNo, row.order_text, row.machine_name);
			// seqNo = seqNo + 1;
		}
		
		function goSave(isRequestAppr) {
			console.log("isRequestAppr : ", isRequestAppr);
			
			var frm = document.main_form;
			// 입력폼 벨리데이션
			if($M.validation(frm) == false) {
				return;
			}

			frm = $M.toValueForm(frm);
			
			// 장비추가내역 벨리데이션
			var data = AUIGrid.getGridData(auiGrid1);
			var gridData1 = AUIGrid.getGridData(auiGrid2);
			console.log("data : ", data);
			if (data.length == 0) {
				alert("장비를 추가해주세요.");
				return;
			}
			
			console.log("auiGrid2 : ", gridData1);
			
			if(fnCheckGridEmpty1(auiGrid1) == false) {
				return;
			}

			// 장비추가내역 그리드
			var gridForm = fnChangeGridDataToForm(auiGrid1);
			$M.copyForm(gridForm, frm);
			
			console.log("gridForm : ", gridForm);
			
			if(isRequestAppr != undefined) {
				$M.setValue("save_mode", "appr"); // 결재요청
				var msg = "";
				var orderFileSeq = $M.getValue("order_file_seq");
				console.log("orderFileSeq : ", orderFileSeq);
				if (orderFileSeq == '' || orderFileSeq == 0) {
					msg = "오더확인서 없이 결재를 상신하면 선적발주서 작성이 불가합니다.\n결재요청을 진행하시겠습니까?";
				} else {
					msg = "결재요청 하시겠습니까?";
				}

				if(confirm(msg) == false) {
					return false;
				}
			} else {
				$M.setValue("save_mode", "save"); // 저장
				if(confirm("저장하시겠습니까?") == false) {
					return false;
				}
			}
			
			$M.goNextPageAjax(this_page + "/save", gridForm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("저장이 완료되었습니다.");
		    			$M.goNextPage("/sale/sale0201");
					}
				}
			);
		}
		
		// 목록
		function fnList() {
			history.back();
		}
		
		function goRequestApproval() {
			goSave('requestAppr');
		}

        // 에디팅이 끝난후에는 에디팅을 못하도록 막는 작업.
		function fnEditControl() {
		  AUIGrid.bind(auiGrid1, ["cellEditBegin"], function(event) {
			  console.log("이벤트 : ", event);
		 	 if(event.dataField == "machine_name") {
		 		 if (event.item.machine_plant_seq == "") {
			    	 return true; 
		 		 } else {
		 			 return false;  // false 반환. 기본 행위인 편집 불가
		 		 }
		  	 }
		  });	
		}

		// (SR : 14481 황빛찬) 해당 메이커로 작성된 가장 최근 발주 내역 상세내역에 세팅.
		// 발주서 복사
		function fnOrderCopy() {
			var clientCustNo = $M.getValue("client_cust_no");
			if (clientCustNo == '' || clientCustNo == undefined) {
				alert("메이커(TO) 선택 후 재시도 해 주세요.");
				return;
			}

			if (confirm("해당 메이커(TO)의 최근 작성된 발주서를 복사 하시겠습니까 ?") == false) {
				return;
			}

			var param = {
				"client_cust_no" : clientCustNo
			};

			$M.goNextPageAjax(this_page + "/order/copy" , $M.toGetParam(param) , {method : 'GET'},
				function(result) {
					if(result.success) {
						if (result.client_charge_name == undefined) {
							$M.clearValue({
								field:[
										"client_charge_name", "client_rep_name", "desc_text", "job_eng_name", "mem_eng_name", "money_unit_cd", "money_unit_name", "order_dt",
										"order_mon", "order_remark", "order_year", "remark_1", "remark_2", "remark_3", "remark_4", "remark_5", "remark_6", "s_start_year", "s_start_mon"
								]
							});
						} else {
							$M.setValue(result);
							$M.setValue("s_start_year", result.order_year);
							$M.setValue("s_start_mon", result.order_mon);
						}
					}
				}
			);
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
			console.log("file : ", file);
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

		// 발주옵션 내용 수정
		function goOrderTextModify(seqNo) {
			var orderText = $("#order_text_" + seqNo).text();
			parentOrderText = orderText;

			var popupOption = "";
			var param = {
				"seq_no" : seqNo,
			};
			$M.goNextPage('/sale/sale0201p03', $M.toGetParam(param), {popupStatus : popupOption});
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

		/**
		 * 발주옵션의 textarea의 height를 텍스트 크기에 따라서 세팅
		 * @param {number} seqNo
		 */
		function setTextAreaHeight(seqNo) {
			const textarea = document.getElementById('order_text_' + seqNo);
			textarea.style.height = "auto";
			textarea.style.height = (textarea.scrollHeight + 2) + "px"; // 스크롤 없애기 위한 2px
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
		}

		function fnRemoveOrderText(seqNo) {
			$("#order_text_div_" + seqNo).remove();
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="save_mode" name="save_mode"> <!-- appr(결재요청 후 저장), save(저장) -->
<input type="hidden" id="mem_no" name="mem_no" value="${result.mem_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${result.appr_proc_status_cd}">
<!-- <input type="hidden" id="opt_code" name="opt_code"> -->
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left approval-left" style="align-items: center;">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
					<!-- 결재영역 -->
					<div class="p10">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
					<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->
<!-- 상단 폼테이블 -->	
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
									<th class="text-right essential-item">발주번호</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<input type="text" class="form-control width100px" readonly id="machine_order_no" name="machine_order_no">
											</div>
										</div>
									</td>
									<th class="text-right">담당자</th>
									<td>
										<input type="text" class="form-control width80px" id="reg_mem_name" name="reg_mem_name" value="${SecureUser.user_name}" readonly alt="담당자"  required="required">
										<input type="hidden" name="reg_id" id="reg_id" value="${SecureUser.mem_no}" >
									</td>
									<th class="text-right">상태</th>
									<td>
										작성중
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">To</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width200px" id="cust_name" name="cust_name" readonly alt="To"  required="required">
											<input type="hidden" id="client_cust_no" name="client_cust_no">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
											<div class="detail-left approval-left" style="align-items: center;">
												<button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="javascript:fnOrderCopy();" style="margin-left:10px;">발주서 복사</button>
											</div>
										</div>
									</td>
									<th rowspan="2" class="text-right essential-item">From</th>
									<td rowspan="2">
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" class="form-control essential-bg" maxlength="40" id="mem_eng_name" name="mem_eng_name" alt="From"  required="required">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="30" id="job_eng_name" name="job_eng_name">
											</div>
										</div>
									</td>
									<th rowspan="5" class="text-right essential-item">Remark</th>
									<td rowspan="5">
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control essential-bg" maxlength="100" id="remark_1" name="remark_1" alt="Remark"  required="required">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_2" name="remark_2">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_3" name="remark_3">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_4" name="remark_4">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_5" name="remark_5">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_6" name="remark_6">
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">Attn</th>
									<td>
										<input type="text" class="form-control essential-bg" maxlength="40" id="client_charge_name" name="client_charge_name" alt="Attn"  required="required">
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">CC</th>
									<td>
										<input type="text" class="form-control essential-bg" maxlength="40" id="client_rep_name" name="client_rep_name" alt="CC"  required="required">
									</td>
									<th class="text-right essential-item">RE</th>
									<td>
										<input type="text" class="form-control essential-bg" maxlength="60" id="order_remark" name="order_remark" alt="RE"  required="required">
									</td>
								</tr>
								<tr>
									<th class="text-right">합계금액</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-4">
												<input type="text" class="form-control text-right width180px" readonly name="total_amt" id="total_amt" format="decimal" alt="합계금액"  required="required">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
									<th class="text-right essential-item">화폐단위</th>
									<td>
										<select class="form-control width100px essential-bg" id="money_unit_cd" name="money_unit_cd" required="required" alt="화폐단위">
											<option value="">- 선택 -</option>
											<c:forEach var="item" items="${codeMap['MONEY_UNIT']}">
												<option value="${item.code_value}">${item.code_value}</option>
											</c:forEach>
										</select>
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">생산완료월</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-3">
													<select class="form-control essential-bg" id="s_start_year" name="s_start_year">
														<c:forEach var="i" begin="${inputParam.s_start_dt - 1}" end="${inputParam.s_start_dt + 2}" step="1">
															<option value="${i}" <c:if test="${i==inputParam.s_start_dt}">selected</c:if>>${i}년</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-2">
													<select class="form-control essential-bg" id="s_start_mon" name="s_start_mon">
														<c:forEach var="i" begin="1" end="12" step="1">
															<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_start_mon}">selected</c:if>>${i}월</option>
														</c:forEach>
													</select>
												</div>			
											</div>
										</td>						
<!-- 									<td> -->
<!-- 										<div class="input-group"> -->
<%-- 											<input type="text" class="form-control border-right-0 essential-bg calDate" id="order_dt" name="order_dt" dateformat="yyyy-MM-dd" alt="발주일자" value="${inputParam.s_end_dt}" required="required"> --%>
<!-- 										</div> -->
<!-- 									</td> -->
								</tr>
								<tr>
									<th class="text-right">참고</th>
									<td colspan="3">
										<input type="text" class="form-control" maxlength="80" id="desc_text" name="desc_text">
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
									<!-- 버튼 스크립트로 변경예정 -->
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
									<button type="button" class="btn btn-default" onclick="javascript:goModelInfoClick();"><i class="material-iconsadd text-default"></i> 장비추가</button>
								</div>
							</div>
							<div id="auiGrid1" style="margin-top: 5px; height: 300px;">
							
										
							</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
							<div class="btn-group mt5">
								<div class="left">
									총 <strong class="text-primary" id="total_cnt">0</strong>건
								</div>						
							</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
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

<!-- /장비추가내역 -->
						</div>
<!-- 우측 폼테이블 -->
						<div class="col-5">
							<div class="title-wrap mt10">
								<h4>발주옵션</h4>
							</div>
							<div class="option-group" style="height: 450px;" id="order_text_div">
							</div>

						</div>
<!-- /우측 폼테이블 -->
					</div>
<!-- /하단 폼테이블 -->	
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
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>