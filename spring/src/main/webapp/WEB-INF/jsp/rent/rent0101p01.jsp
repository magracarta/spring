<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 렌탈신청현황 > null > 렌탈신청상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>
		var auiGrid;
		
		var isRfq = false; // 견적서 참조했는지 여부
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridRight();
			fnInit();

			// 2025-02-19 최승희대리는 모든 버튼 노출
			if ("${SecureUser.mem_no}" != "MB00000133") {
				// 배정자 외에는 하단 버튼 노출 X - 2025.01.14 박동훈
				if ("${rental_assign_mem_no}" == "") {
					$("#_fnOutRequest,#_goSale,#_goResv,#_goConfirmResv,#_goCancelResv,#_goModify,#_goRemove").hide();
				}else {
					if ("${page.fnc.F00965_001}" != "Y" && "${rental_assign_mem_no}" != "${SecureUser.mem_no}") {
						$("#_fnOutRequest,#_goSale,#_goResv,#_goConfirmResv,#_goCancelResv,#_goModify,#_goRemove").hide();
					}
				}
			}
		});
		
		function fnChangeDeliveryCd(init) {
			$(".two_way_yn").hide();
			var cd = $M.getValue("rental_delivery_cd");
			if (cd == "01") {
				$(".dc *").attr("disabled", true);
				$(".r1s").removeClass("rs");
			} else {
				$(".dc *").attr("disabled", false);
				$(".r1s").addClass("rs");
			}
			if (cd == "03" || cd == "04") {
				$("#transport_amt").prop('disabled', false);
				if (cd == "04") {
					if (init == undefined) {
						alert("운송사 착불을 유도하고 불가피 할 경우에만 사용 하시고 수주매출로 따로 운송비처리하는 것을 금지합니다.");
					}
				}
				if (cd == "03") {
					$(".two_way_yn").show();
				}
			} else {
				$M.setValue("transport_amt", "0");
				$("#transport_amt").prop('disabled', true);
			} 
			fnCalc();
		}
		
		function fnInit() {
			fnChangeDeliveryCd('init');

			<c:if test="${rent.paper_file_seq ne 0}">
			fnPrintFile('${rent.paper_file_seq}','${rent.paper_file_name}');
			$('#paperFileBtn').remove();
			</c:if>

			// 매출처리 전까지, 렌탈확정 숨김
			$("#_goConfirmResv").css("display", "none");
			if ("Y" == "${rent.inout_proc_yn}") {
				// 매출처리 시, 매출처리 버튼 숨김
				$("#_goSale").css("display", "none");
				
				// 매출처리 시, 삭제버튼 숨김
				$("#_goRemove").css("display", "none");
				
				// 매출처리 시, 수정버튼 숨김
				$("#_goModify").css("display", "none");
			} else {
				$("#_goConfirmResv").css("display", "inline-block;");	
			}
			
			// 예약상태면 예약버튼 숨김
			if ("${rent.rental_status_cd}" == "02") {
				$("#_goResv").css("display", "none");
			} else if ("${rent.rental_status_cd}" != "02") {
				$("#_goCancelResv").css("display", "none");
			}
			
			// 예약확정이면 예약, 수정, 삭제를 숨기고 예약취소를 보여줌
			if ("${rent.rental_status_cd}" == "03") {
				$("#_goResv").css("display", "none");
				$("#_goRemove").css("display", "none");
				$("#_goModify").css("display", "none");
				$("#_goCancelResv").css("display", "inline-block");
			}
			
			// 렌탈확정 시, 변경 불가
			if ("${rent.rental_status_cd }" == "04" || ("${rent.rental_status_cd }" > "05")) { 
				$("#rental_delivery_cd").prop("disabled", true);
				$("#btnAttach").prop("disabled", true);
				$("#rental_st_dt").prop("disabled", true);
				$("#rental_ed_dt").prop("disabled", true);
				$("#discount_amt").prop("disabled", true);
				
				$("#_goResv").css("display", "none");
				$("#_goCancelResv").css("display", "none");
				$("#_goModify").css("display", "none");
				$("#_goRemove").css("display", "none");
				$("#_goResv").css("display", "none");
			}
			
			if ("${rent.rfq_no}" != "") {
				isRfq = true;
				$("#btnRefer").html("(견)"+"${rent.rfq_no}");
				$("#rental_st_dt").attr("disabled", true);
				$("#rental_ed_dt").attr("disabled", true);
			}
		}
		
		function goReferEstimate() {
			var param = {
				rfq_no : "${rent.rfq_no}",
				disabled_yn : "Y" 
			}
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=600, left=0, top=0";
			$M.goNextPage('/cust/cust0107p04', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		function createAUIGridRight() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showSelectionBorder : true,
				rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
					// 공지가 등록된 경우 체크 불가
					if (item.able_yn =='N') {
						return false;
					}

					return true;
				},
				independentAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					headerText : "어태치먼트명",
					dataField : "attach_name",
					width : "200",
					style : "aui-left"
				},
				{
					headerText : "총수량",
					dataField : "total_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "렌탈중",
					dataField : "rental_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "가용수량",
					dataField : "able_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "렌탈금액",
					dataField : "amt",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					visible : false,
				},
				{
					headerText : "수량",
					dataField : "qty",
					visible : false,
				},
				{
					headerText : "매입처",
					dataField : "client_name",
					visible : false,
				},
				{
					headerText : "일련번호",
					dataField : "product_no",
					visible : false,
				},
				{
					headerText : "렌탈일수",
					dataField : "day_cnt",
					visible : false,
				},
<%--				<c:if test="${rent.rental_status_cd  < '04' or rent.rental_status_cd eq '05'}">--%>
<%--				{--%>
<%--					headerText : "삭제",--%>
<%--					dataField : "h",--%>
<%--					renderer : {--%>
<%--						type : "ButtonRenderer",--%>
<%--						onClick : function(event) {--%>
<%--							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);--%>
<%--							if (isRemoved == false) {--%>
<%--								AUIGrid.removeRow(event.pid, event.rowIndex);--%>
<%--								fnCalc();--%>
<%--							} else {--%>
<%--								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");--%>
<%--								getAttachPrice();--%>
<%--							}--%>
<%--						}--%>
<%--					},--%>
<%--					labelFunction : function(rowIndex, columnIndex, value,--%>
<%--							headerText, item) {--%>
<%--						return '삭제'--%>
<%--					}--%>
<%--				},--%>
<%--				</c:if>--%>
				{
					dataField : "rental_attach_no",
					visible : false
				},
				{
					dataField : "cmd",
					visible : false
				},
				{
					dataField : "cost_yn",
					visible : false
				},
				{
					dataField : "base_yn",
					visible : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${allAttach});
			<c:if test="${not empty attach}">
			var attachList = ${attach};
			var checkList = [];

			var auiGridData = AUIGrid.getGridData(auiGrid);
			for (var i = 0; i < attachList.length; ++i) {
				var exists = false;
				for(var j = 0; j < auiGridData.length; j++) {
					if(attachList[i].part_no == auiGridData[j].part_no && auiGridData[j].able_yn != "N") {
						checkList.push(attachList[i].part_no);
						AUIGrid.updateRow(auiGrid,{"able_yn" : "Y", "amt" : attachList[i].amt}, j);
						exists = true;
						break;
					}
				}
				if(!exists) {
					AUIGrid.addRow(auiGrid, attachList[i], 'last');
				}
			}
			AUIGrid.setCheckedRowsByValue(auiGrid, "part_no", checkList);
			getAttachPrice();
			</c:if>

			AUIGrid.bind(auiGrid, "rowAllChkClick", function( event ) {
				if(event.checked) {
					var uniqueValues = AUIGrid.getGridData(auiGrid);
					var list = [];
					for (var i = 0; i < uniqueValues.length; ++i) {
						if (uniqueValues[i].able_yn != "N") {
							list.push(uniqueValues[i].part_no);
						}
					}
					AUIGrid.setCheckedRowsByValue(event.pid, "part_no", list);
				} else {
					AUIGrid.setCheckedRowsByValue(event.pid, "part_no", []);
				}
			});

			AUIGrid.bind(auiGrid, "rowCheckClick", function( event ) {
				getAttachPrice();
			});
		}

		function fnOutRequest() {
			var msg = "출고요청 쪽지를 발송하시겠습니까?";
			var param = {
				"rental_doc_no" : $M.getValue("rental_doc_no"),
				"mng_org_code" : "${rent.mng_org_code}",
				"rental_st_dt" : $M.getValue("rental_st_dt"),
				"rental_ed_dt" : $M.getValue("rental_ed_dt"),
				"machine_name" : "${rent.machine_name}",
				"body_no" : "${rent.body_no}",
				"rental_delivery_name" :"${rent.rental_delivery_name}",
				"addr" : "${rent.delivery_addr1}" + " " + "${rent.delivery_addr2}",
				"cust_name" : "${rent.cust_name}",
				"hp_no" : "${rent.hp_no}",
				"inout_doc_no" : "${rent.inout_doc_no[0]}",
			}

			$M.goNextPageAjaxMsg(msg, this_page + "/out_request", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
						}
					}
			);
		}
		
		function goProcess(c) {
			// IE fix
			var control = c;
			var frm = document.main_form;
			if (control != "D") {
				if($M.validation(frm) == false) {
					return;
				}
				if ($M.getValue("rental_delivery_cd") != "01" && $M.getValue("rental_delivery_cd") != "") {
					if($M.validation(frm, {field : ["delivery_post_no"]}) == false) {
						return;
					};
				} 
				if($M.checkRangeByFieldName("rental_st_dt", "rental_ed_dt", true) == false) {				
					return;
				}; 
			}
			$M.getValue("contract_make_yn_check") == "" ? $M.setValue("contract_make_yn", "N") : $M.setValue("contract_make_yn", "Y");
	    	$M.getValue("id_copy_yn_check") == "" ? $M.setValue("id_copy_yn", "N") : $M.setValue("id_copy_yn", "Y");
	    	$M.getValue("norm_rental_yn_check") == "" ? $M.setValue("norm_rental_yn", "N") : $M.setValue("norm_rental_yn", "Y");
	    	$M.getValue("long_rental_yn_check") == "" ? $M.setValue("long_rental_yn", "N") : $M.setValue("long_rental_yn", "Y");
	    	$M.getValue("paper_file_seq") == "" ? $M.setValue("paper_file_seq", 0) : {};
			frm = $M.toValueForm(frm);
			var gridForm = fnCheckedGridDataToForm(auiGrid);
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);
			var msg;
			if (control == "M") {
				msg = "수정하시겠습니까?";
			} else if (control == "R"){
				msg = "예약하시겠습니까?";
			} else if (control == "RC"){
				msg = "렌탈확정하시겠습니까?";
			} else if (control == "CR"){
				msg = "예약취소하시겠습니까?";
			} else if (control == "D") {
				msg = "삭제하시겠습니까?";
			} else if (control == "SALE") {
				msg = "매출처리하시겠습니까?";

				if(('${modusignMap.file_seq}' == '' || '${modusignMap.file_seq}' == '0') && ($M.getValue("paper_file_seq") == '' || $M.getValue("paper_file_seq") == '0')) {
					alert('전자서명이 완료되거나 종이계약서 업로드 시 매출처리가 가능합니다.');
					return false;
				}
			}
			$M.goNextPageAjaxMsg(msg, this_page, gridForm, {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			if (control == "SALE") {
			    				setTimeout(function() {
			    					var param = {
				    					rental_doc_no : $M.getValue("rental_doc_no")
				    				}
				    				openInoutProcPanel("fnSetSaleResult", $M.toGetParam(param));
			    				}, 10);
			    			} else if (control == "D") {
			    				if (opener != null && opener.goSearch) {
			    					opener.goSearch();
			    				}
			    				fnClose();
			    			} else {
			    				alert("처리가 완료되었습니다.");
			    				location.reload();
			    			}
						}
					}
				);
		}
		
		// 매출처리
		function goSale() {
			$M.setValue("mode", "S");
			goProcess("SALE");
		} 
		
		function fnSetSaleResult() {
			location.reload();
		}
		
		function fnClose() {
			window.close(); 
		}
		
		// 수정
		function goModify() {
			$M.setValue("mode", "M");
			goProcess("M");
		}
		
		// 예약
		function goResv() {
			$M.setValue("mode", "R");
			goProcess("R");
		}
		
		// 예약취소
		function goCancelResv() {
			$M.setValue("mode", "CR");
			goProcess("CR");
		}
		
		// 예약확정
		function goConfirmResv() {
			alert("매출처리를 먼저하세요.");
			$M.setValue("mode", "RC");
			goProcess("RC");
		}
		
		// 삭제
		function goRemove() {
			$M.setValue("mode", "D");
			goProcess("D");
		}
		
		// 임대차계약서인쇄
	    function goPrint() {
			var params = {
				"rental_doc_no" : '${rent.rental_doc_no}',
				"rental_machine_no" : '${rent.rental_machine_no}'
			}

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=720, height=250, left=0, top=0";
			$M.goNextPage('/comp/comp1002', $M.toGetParam(params), {popupStatus : popupOption});

			// [재호] [3차-Q&A 15591] 렌탈 신청 상세 수정 추가
			// - 고객명, 회사명 선택 팝업 추가
	    	// openReportPanel('rent/rent0101p01_01.crf','rental_doc_no=' + $M.getValue("rental_doc_no"));

			<%--if(${empty modusignMap.file_seq or modusignMap.file_seq eq '0'}) {--%>
			<%--	alert("모두싸인 문서 서명이 완료되지 않았습니다.\n완료 후 다시 확인해주세요.");--%>
			<%--	return;--%>
			<%--} else {--%>
			<%--	openFileViewerPanel('${modusignMap.file_seq}');--%>
			<%--}--%>
	    }
		
	    function fnSetArrival1Addr(row) {
	        var param = {
		        delivery_post_no: row.zipNo,
		        delivery_addr1: row.roadAddr,
		        delivery_addr2: row.addrDetail
	        };
	        $M.setValue(param);
	    }
		
		
		//어태치먼트추가
	    function goAttachPopup() {
	    	var rows = AUIGrid.getGridData(auiGrid);
			// 2020-08-10 회의
			// 이동, 재렌탈는 소유센터의  어태치만 조회
			// 고객렌탈일떄는 관리센터의 어태치만 조회
	     	var params = {
	     		mng_org_code : "${rent.mng_org_code}",
	     		rental_machine_no : $M.getValue("rental_machine_no"),
	     		// not_rental_attach_no : $M.getArrStr(rows, {key : 'rental_attach_no'}),
				apply_yn : 'N',
		    };
		    openRentalAttachPanel("fnSetAttach", $M.toGetParam(params));
	    }
		
		function fnSetAttach(row) {
			var item = new Object();
			if(row != null) {
				for(i=0; i<row.length; i++) {
					item.part_name = row[i].part_name;
					item.part_no = row[i].part_no;
					item.attach_name = row[i].attach_name;
					item.qty = 1;
					item.product_no = row[i].product_no;
					item.client_name = row[i].client_name;
					item.rental_attach_no = row[i].rental_attach_no;
					item.day_cnt = $M.getValue("day_cnt");
					item.amt = 0;
					item.cost_yn = row[i].cost_yn;
					item.base_yn = row[i].base_yn;
					AUIGrid.addRow(auiGrid, item, 'last');
				}
				getAttachPrice();
			}
			AUIGrid.resize(auiGrid);
		}
	    
	    // 고객조회 결과 test
	    function fnSetCustInfo(row) {
			var param = {
					hp_no : $M.phoneFormat(row.real_hp_no),
					cust_name : row.real_cust_name,
					cust_no : row.cust_no,
					addr1 : row.addr1,
					addr2 : row.addr2,
					breg_name : row.breg_name,
					breg_no : row.breg_no,
					email : result.email,
					breg_type_name : result.breg_type_name,
					machine_has_yn : result.machine_has_yn,
					total_rental_cnt : result.total_rental_cnt,
					year_rental_cnt : result.year_rental_cnt,
			}
			$M.setValue(param);
			$('#breg_type_name').html(result.breg_type_name);
			fnRentalDayCheck();
	    }
	    
	    function fnSetDayCnt() {
	    	if ($M.getValue("rental_st_dt") == "" || $M.getValue("rental_ed_dt") == "") {
	    		$M.setValue("day_cnt", 0);
	    	} else {
	        	var cnt = $M.getDiff($M.getValue("rental_ed_dt"), $M.getValue("rental_st_dt"));
	        	if (cnt < 1) {
	        		$M.setValue("rental_ed_dt", $M.getValue("rental_st_dt"));
	        		alert("렌탈 종료가 렌탈 시작 이전 입니다.");
	        		$M.setValue("day_cnt", 1);	
	        	} else {
	        		$M.setValue("day_cnt", cnt);
	        	}
	    		getMachinePrice();
	    	}
			fnRentalDayCheck();

	    	AUIGrid.resize(auiGrid);
	    }

		function fnRentalDayCheck() {
			var dayCnt = $M.toNum($M.getValue("day_cnt"));
			if(dayCnt < 8) {
				$M.setValue("rental_day_check", "A");
			} else if(dayCnt >= 8 && dayCnt < 32) {
				$M.setValue("rental_day_check", "B");
			} else {
				$M.setValue("rental_day_check", "C");
			}
		}
	    
	    function getMachinePrice() {
	    	if ($M.getValue("day_cnt") == "") {
	    		return false;
	    	}
	    	var param = {
	    		rental_machine_no : $M.getValue("rental_machine_no"),
	    		day_cnt : $M.getValue("day_cnt")
	    	}
			$M.goNextPageAjax("/rent/rent010101/calc/machine", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			$M.setValue("machine_rental_price", result.price);
			    			getAttachPrice();
						}
					}
				);
	   }
	    
	   function getAttachPrice() {
		    var rows = AUIGrid.getGridData(auiGrid);
	    	var dayCnt = $M.toNum($M.getValue("day_cnt"));
	    	if (rows.length < 1 || dayCnt == 0) {
	    		fnCalc();
	    		return false;
	    	}
	    	var dayArr = [];
	    	for (var i = 0; i < rows.length; ++i) {
	    		dayArr.push(dayCnt);
	    		AUIGrid.updateRow(auiGrid, {"day_cnt" : dayCnt },i);
	    	}
	    	var param = {
	    		rental_attach_no_str : $M.getArrStr(rows, {sep : "#", key : "rental_attach_no", isEmpty : true}),
	    		day_cnt_str : $M.getArrStr(dayArr),
	    		base_yn_str : $M.getArrStr(rows, {sep : "#", key : "base_yn", isEmpty : true}),
	    		cost_yn_str : $M.getArrStr(rows, {sep : "#", key : "cost_yn", isEmpty : true}),
	    	}
			$M.goNextPageAjax("/rent/rent010101/calc/attach", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			console.log(result);
			    			var total = 0;
			    			for (var i = 0; i < result.attachPrice.length; ++i) {
			    				total+=result.attachPrice[i];
			    				var obj = {
			    					amt :  result.attachPrice[i]
			    				}
			    				AUIGrid.updateRow(auiGrid, obj, i);
			    			}
			    			fnCalc();
						}
					}
				);
	    }
	   
	   function fnCalc() {
		   var machine_rental_price = $M.toNum($M.getValue("machine_rental_price"));
		   var sumAttachAmt = 0;
		   var gridData = AUIGrid.getCheckedRowItemsAll(auiGrid);
		   for (var i = 0; i < gridData.length; ++i) {
			   var isRemoved = AUIGrid.isRemovedById(auiGrid, gridData[i]._$uid);
			   if (!isRemoved) {
				   sumAttachAmt+=$M.toNum(gridData[i].amt*gridData[i].qty);
			   }
		   }
		   var attach_rental_price = sumAttachAmt; // $M.toNum($M.getValue("attach_rental_price"));
		   $M.setValue("attach_rental_price", attach_rental_price);
		   var total_rental_amt = machine_rental_price + attach_rental_price;
		   var discount_amt = $M.toNum($M.getValue("discount_amt"));
		   var total_amt = total_rental_amt - discount_amt;
		   $M.setValue("total_rental_amt", total_rental_amt);
		   var transport_amt = $M.toNum($M.getValue("transport_amt"));
		   if ($M.getValue("rental_delivery_cd") == "03" || $M.getValue("rental_delivery_cd") == "04") {
			   total_amt += transport_amt;
		   }
		   var tempTotalAmt = total_amt;
		   var mch_deposit_amt = $M.toNum($M.getValue("mch_deposit_amt"));
		   total_amt = total_amt + mch_deposit_amt;
		   $M.setValue("rental_amt", total_amt);
		   // $M.setValue("vat_rental_amt", Math.floor(total_amt*1.1));
		   $M.setValue("vat_rental_amt", Math.floor(tempTotalAmt*1.1) + mch_deposit_amt);
 	   }
	   
	   
		// 수익배분
		function fnSetProfit01(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_01", row.mem_no);
			$M.setValue("profit_mem_name_01", row.mem_name);
		}
		
		function fnSetProfit02(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_02", row.mem_no);
			$M.setValue("profit_mem_name_02", row.mem_name);
		}
		
		function fnSetProfit03(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_03", row.mem_no);
			$M.setValue("profit_mem_name_03", row.mem_name);
		}
		
		function goSearchMemberPanel(fn) {
			var param = {
				"agency_yn" : "N"
			}									
			openMemberOrgPanel(fn, "N" , $M.toGetParam(param));
		}
		
		// 업무DB 연결 함수 21-08-06이강원
     	function openWorkDB(){
     		openWorkDBPanel('',${rent.machine_plant_seq});
     	}

		// [재호] [3차-Q&A 15591] 장비대장 추가
		// 장비 대장 상세
		function goMachineDetail() {
			// 보낼 데이터
			var params = {
				"s_machine_seq" : '${rent.machine_seq}'
			};
			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
			$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		// 렌탈이력
		function goRentalHisPopup() {
			var params = {
				machine_name : "${rent.machine_name}",
				body_no : "${rent.body_no}",
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p04', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		//이동이력
		function goMoveHisPopup() {
			var params = {
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p05', $M.toGetParam(params), {popupStatus : popupOption});

		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		//수리이력
		function goAsHisPop() {
			var params = {
				s_machine_seq : "${rent.machine_seq}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		// 렌탈장비대장
		function goRentalMachineDetail() {
			var params = {
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=520, left=0, top=0";
			$M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 모두싸인 요청 (저장 후 진행)
		function sendModusignPanel() {
			if($M.getValue("cust_no") == "") {
				alert("고객선택 후 진행해주세요.");
				return;
			}

			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}

			var params = {
				"cust_name" : $M.getValue("cust_name"),
				"hp_no" : $M.getValue("hp_no"),
				"email" : $M.getValue("email"),
				"breg_name" : $M.getValue("breg_name"),
				"confirm_msg" : "저장된 내용으로 싸인 문서가 생성되므로,\n내용 변경시 저장 및 싸인취소 후 다시 재진행하셔야 합니다.",
				// "confirm_msg" : "발송 시 저장하지 않은 내용은 계약서에 반영되지 않습니다.\n발송하시겠습니까?",
			}

			openSendModusignPanel('sendModusignAfterSave', $M.toGetParam(params));
		}

		// 모두싸인 요청 (저장 후 진행)
		function sendContactModusignPanel() {
			if($M.getValue("cust_no") == "") {
				alert("고객선택 후 진행해주세요.");
				return;
			}

			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}

			var params = {
				"cust_name" : $M.getValue("cust_name"),
				"hp_no" : $M.getValue("hp_no"),
				"email" : $M.getValue("email"),
				"breg_name" : $M.getValue("breg_name"),
				"confirm_msg" : "저장된 내용으로 싸인 문서가 생성되므로,\n내용 변경시 저장 및 싸인취소 후 다시 재진행하셔야 합니다.",
				// "confirm_msg" : "발송 시 저장하지 않은 내용은 계약서에 반영되지 않습니다.\n발송하시겠습니까?",
			}

			openSendContactModusignPanel('sendModusignAfterSave', $M.toGetParam(params));
		}

		function sendModusignAfterSave(data) {

			var param = {
				"cust_breg_name" : data.cust_name,
				"modusign_doc_cd" : 'RENTAL_DOC',
				"modusign_send_cd" : data.modusign_send_cd,
				"send_hp_no" : data.modusign_send_value,
				"hp_no" : data.modusign_send_value,
				"send_email" : data.modusign_send_value,
				"modusign_cust_app_yn" : data.modusign_send_cd == 'SECURE_LINK' ? 'Y' : 'N',
				"rental_doc_no" : $M.getValue("rental_doc_no"),
				"rental_depth" : $M.getValue("rental_depth"),
				"modu_modify_yn" : $M.getValue("modu_modify_yn") == ""? "N":$M.getValue("modu_modify_yn")
			};

			$M.goNextPageAjax("/modu/request_document", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
			);
		}

		function sendModusignCancel() {
			var msg = "싸인을 취소하시겠습니까?";

			var param = {
				"modusign_id" : "${rent.modusign_id}",
			};

			$M.goNextPageAjaxMsg(msg, "/modu/request/cancel", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
			);
		}

		function fnModusignModify() {
			var frm = document.main_form;

			$("#_sendModusignPanel").show();
			$("#_sendContactModusignPanel").show();
			$("#_fnModusignModify").hide();
			$("#_file_name").hide();
			$M.setValue(frm, "modu_modify_yn", "Y");
		}

		// 첨부파일 출력
		function fnPrintFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item paper_file" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="paper_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile()"><i class="material-iconsclose font-16 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.paper_file_div').append(str);
		}

		// 첨부파일 버튼 클릭
		function fnAddFile(){
			if($M.getValue("paper_file_seq") != "0" && $M.getValue("paper_file_seq") != "") {
				alert("파일은 1개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=RENT&file_type=img&max_size=10240');
		}

		function setFileInfo(result) {
			fnPrintFile(result.file_seq, result.file_name);
			$('#paperFileBtn').remove();
		}

		// 첨부파일 삭제
		function fnRemoveFile() {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".paper_file").remove();
				$(".paper_file_td").append('<button type="button" class="btn btn-primary-gra" id="paperFileBtn" onclick="javascript:fnAddFile()" >파일찾기</button>');
			} else {
				return false;
			}
		}
		
	</script>
</head>
<body   class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="mode">
<input type="hidden" name="contract_make_yn">
<input type="hidden" name="id_copy_yn">
<input type="hidden" name="norm_rental_yn">
<input type="hidden" name="long_rental_yn">
<input type="hidden" name="rental_machine_no" value="${rent.rental_machine_no}">
<input type="hidden" name="rental_doc_no" value="${rent.rental_doc_no }">
<input type="hidden" name="up_rental_doc_no" value="${rent.up_rental_doc_no }">
<input type="hidden" name="c_rental_request_seq" value="${rent.c_rental_request_seq }">
<input type="hidden" name="pre_paper_file_seq" value="${rent.pre_paper_file_seq }">
<input type="hidden" name="rental_depth" value="${rent.rental_depth }">
<input type="hidden" name="modu_modify_yn" value="${modusignMap.modu_modify_yn}">
<input type="hidden" name="s_self_assign_no" value="${inputParam.s_self_assign_no}">
<!-- 팝업 -->
	<div class="popup-wrap width-100per" style="min-width: 1385px;">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="row">
				<div class="col-6">
<!-- 장비정보 -->
					<div class="title-wrap approval-left">
						<h4>장비정보</h4>
						<div class="right">
							<span class="condition-item">상태 :
								<c:choose>
									<c:when test="${empty rent.rental_status_name }">작성중</c:when>
									<c:otherwise>
										${rent.rental_status_name }
									</c:otherwise>
								</c:choose> 
							</span>
						</div>
					</div>			
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
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">메이커</th>
								<td colspan="3">
									<input type="text" class="form-control width120px" readonly="readonly" value="${rent.maker_name}">
								</td>
								<th class="text-right">모델</th>
								<td colspan="3">
									<div class="form-row inline-pd pr">
										<div class="col-auto">
											<div class="input-group">
												<input type="text" class="form-control width120px" readonly="readonly" value="${rent.machine_name}" style="display: inline-block;">
												<c:if test="${not empty rent.rfq_no}">
													<button type="button" class="btn btn-primary-gra spacing-sm" style="display: inline-block;" onclick="javascript:goReferEstimate();" id="btnRefer">견적서참조</button>
												</c:if>
											</div>
										</div>
							            <div class="col-auto">
					                        <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
							            </div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">연식</th>
								<td colspan="3">
									<input type="text" class="form-control width60px" readonly="readonly" value="${fn:substring(rent.made_dt,0,4)}">
								</td>
								<th class="text-right">가동시간</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" class="form-control" readonly="readonly" value="${rent.op_hour }" format="decimal" id="op_hour" name="op_hour">
										</div>
										<div class="col width22px">hr</div>
									</div>
								</td>	
							</tr>
							<tr>
								<th class="text-right">차대번호</th>
								<td colspan="3">
									<div style="display: flex">
										<input type="text" class="form-control width180px" style="margin-right: 10px" readonly="readonly" value="${rent.body_no }">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
									</div>
								</td>
								<th class="text-right">번호판번호</th>
								<td colspan="3">
									<input type="text" class="form-control width120px" readonly="readonly" value="${rent.mreg_no }">
								</td>
							</tr>
							<tr>
								<th class="text-right">GPS</th>
								<td colspan="3">
									<c:choose>
										<c:when test="${not empty rent.sar }">
											<span class="underline" onclick="javascript:window.open('https://terra.smartassist.yanmar.com/machine-operation/map')">SA-R</span>
										</c:when>
										<c:otherwise>
											<input type="hidden" id="gps_seq" name="gps_seq" value="${rent.gps_seq}" >
											<div class="form-row inline-pd widthfix">
												<div class="col width33px text-right">
													종류
												</div>
												<div class="col width80px">
													<select class="form-control" id="gps_type_cd" name="gps_type_cd" disabled="disabled">
														<option value="">- 선택 -</option>
														<c:forEach items="${codeMap['GPS_TYPE']}" var="codeitem">
															<option value="${codeitem.code_value}" ${rent.gps_type_cd eq codeitem.code_value ? 'selected="selected"' : ''}>${codeitem.code_name}</option>
														</c:forEach>
													</select>
												</div>
												<div class="col width55px text-right">
													개통번호
												</div>
												<div class="col width100px">
													<input type="text" class="form-control underline" readonly="readonly" id="gps_no" name="gps_no" value="${rent.gps_no}" onclick="javascript:window.open('http://s1.u-vis.com')">
												</div>
											</div>
										</c:otherwise>
									</c:choose>
								</td>
								<th class="text-right">관리센터</th>
								<td>
									<input type="text" class="form-control width120px" readonly="readonly" value="${rent.mng_org_name }">
								</td>
								<th class="text-right">소유센터</th>
								<td>
									<input type="text" class="form-control width120px" readonly="readonly" value="${rent.own_org_name }">
								</td>
							</tr>										
						</tbody>
					</table>			
<!-- /장비정보 -->	
				</div>
				<div class="col-6">
<!-- 고객정보 -->
					<div class="title-wrap">
						<h4>고객정보</h4>
						<div class="right mt-5">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
							<button type="button" class="btn btn-md btn-rounded btn-outline-primary"  onclick="javascript:goPrint();" ><i class="material-iconsprint text-primary"></i> 임대차계약서인쇄</button>
						</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="80px">
							<col width="140px">
							<col width="100px">
							<col width="120px">
							<col width="100px">
							<col width="120px">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right rs">고객명/휴대전화</th>
								<td colspan="2">
									<div class="row">
										<div class="col-7">
											<div class="input-group">
												<input type="text" class="form-control border-right-0" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명" value="${rent.cust_name }">
												<input type="hidden" id="cust_no" name="cust_no" value="${rent.cust_no }">
												<!-- <button type="button" class="btn btn-icon btn-primary-gra"  onclick="javascript:openSearchCustPanel('fnSetCustInfo');" ><i class="material-iconssearch" ></i></button> -->
												<input type="hidden" name="__s_cust_no" value="${rent.cust_no}">
												<input type="hidden" name="__s_hp_no" value="${rent.hp_no}">
												<input type="hidden" name="__s_cust_name" value="${rent.cust_name}">
												<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
													<jsp:param name="li_type" value="__ledger#__sms_popup#__sms_info#__check_required#__cust_rental_history#__rental_consult_history"/>
												</jsp:include>
											</div>
										</div>
									</div>
										<div class="col-4">
											<input type="text" class="form-control width120px" readonly="readonly" id="hp_no" name="hp_no" value="${rent.hp_no }" format="tel">
										</div>
									</div>
								</td>
								<th class="text-right">업체명/사업자번호</th>
								<td colspan="2">
									<div class="row">
										<div class="col-6">
											<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name" value="${rent.breg_name }">
										</div>
										<div class="col-6">
											<input type="text" class="form-control" readonly="readonly" id="breg_no" name="breg_no" value="${rent.breg_no }" format="bregno">
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">주소</th>
								<td colspan="5">
									<div class="row">
										<div class="col-6">
											<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1" value="${rent.addr1 }">
										</div>
										<div class="col-6">
											<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2" value="${rent.addr2 }">
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">사업자등록구분</th>
								<td>
									<div id="breg_type_name">
										${rent.breg_type_name}
									</div>
								</td>
								<th class="text-right">장비보유여부</th>
								<td>
									<div class="row" style="margin-left:1px;">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="machine_has_yn_y" name="machine_has_yn" value="Y" <c:if test="${rent.machine_has_yn == 'Y'}">checked="checked"</c:if> disabled>
											<label class="form-check-label" for="machine_has_yn_y">보유</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="machine_has_yn_n" name="machine_has_yn" value="N" <c:if test="${rent.machine_has_yn == 'N'}">checked="checked"</c:if> disabled>
											<label class="form-check-label" for="machine_has_yn_n">미보유</label>
										</div>
									</div>
								</td>
								<th class="text-right" rowspan="2">계약일수</th>
								<td rowspan="2">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="day_cnt_under_7" name="rental_day_check" value="A" <c:if test="${rent.rental_day_check == 'A'}">checked="checked"</c:if> disabled>
										<label class="form-check-label" for="day_cnt_under_7">7일 이하</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="day_cnt_under_31" name="rental_day_check" value="B" <c:if test="${rent.rental_day_check == 'B'}">checked="checked"</c:if> disabled>
										<label class="form-check-label" for="day_cnt_under_31">8~31일</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="day_cnt_over_31" name="rental_day_check" value="C" <c:if test="${rent.rental_day_check == 'C'}">checked="checked"</c:if> disabled>
										<label class="form-check-label" for="day_cnt_over_31">32일 이상</label>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">당년 렌탈이력</th>
								<td>
									<div class="row">
										<div class="col-6">
											<input type="text" class="form-control" readonly="readonly" id="year_rental_cnt" name="year_rental_cnt" value="${rent.year_rental_cnt}">
										</div>
										회
									</div>
								</td>
								<th class="text-right">총 렌탈이력</th>
								<td>
									<div class="row">
										<div class="col-6">
											<input type="text" class="form-control" readonly="readonly" id="total_rental_cnt" name="total_rental_cnt" value="${rent.total_rental_cnt}">
										</div>
										회
									</div>
								</td>
							</tr>
						</tbody>
					</table>
					<div class="text-warning" style="text-align: right;">※ 대형법인의 개념 : 대기업 / 상장사 / 중견기업 / 담당자 판단하에 업체 규모가 크다고 판단하는 경우 선택</div>
<!-- /고객정보 -->	
				</div>
			</div>
			<div class="row mt10">
				<div class="col-6">
<!-- 렌탈정보 -->
					<div class="title-wrap approval-left">
						<div class="left">
							<h4>렌탈정보</h4>
							<div class="right text-warning ml5">
								1일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_1_price}" />&nbsp;&nbsp;
								7일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_7_price}" />&nbsp;&nbsp;
								15일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_15_price}" />&nbsp;&nbsp;
								30일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_30_price}" />
							</div>
						</div>
					</div>			
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
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">관리번호</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width130px">
											<%-- <input type="text" class="form-control" readonly="readonly" value="${fn:split(rent.rental_doc_no,'-')[0]}"> --%>
											<input type="text" class="form-control" readonly="readonly" value="${rent.rental_doc_no}">
										</div>
										<%-- <div class="col width16px text-center">-</div>
										<div class="col width50px">
											<input type="text" class="form-control" readonly="readonly" value="${fn:split(rent.rental_doc_no,'-')[1]}">
										</div> --%>
									</div>
								</td>	
								<th class="text-right">담당자</th>
								<td colspan="3">
									<input type="text" class="form-control width100px" readonly="readonly" value="${rent.receipt_mem_name }">
								</td>
							</tr>
							<tr>
								<th class="text-right rs">렌탈기간</th>
								<td colspan="7">
									<div class="form-row inline-pd widthfix">
										<div class="col width110px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate rb" id="rental_st_dt" name="rental_st_dt" dateFormat="yyyy-MM-dd" alt="렌탈 시작일" value="${rent.rental_st_dt }" onchange="fnSetDayCnt()" required="required">
											</div>
										</div>
										<div class="col width16px text-center">~</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate rb" id="rental_ed_dt" name="rental_ed_dt" dateFormat="yyyy-MM-dd" alt="렌탈 종료일" value="${rent.rental_ed_dt }" onchange="fnSetDayCnt()" required="required">
											</div>
										</div>
										<div class="col width50px text-right">
											<input type="text" class="form-control text-right" readonly="readonly" id="day_cnt" name="day_cnt" value="${rent.day_cnt}" format="decimal">
										</div>
										<div class="col width16px">
											일
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right rs">인도방법</th>
								<td colspan="3">
									<select class="form-control width130px rb inline" id="rental_delivery_cd" name="rental_delivery_cd" required="required" alt="인도방법" onchange="javascript:fnChangeDeliveryCd()">
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['RENTAL_DELIVERY']}" var="item">
											<option value="${item.code_value}" <c:if test="${item.code_value eq rent.rental_delivery_cd}">selected="selected"</c:if>>${item.code_name}</option>
										</c:forEach>
									</select>
									<div style="display: inline-block; vertical-align: middle; margin-left: 5px;">
										<div class="two_way_yn" style="display: none;">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="two_way_yn_n" name="two_way_yn" value="N" <c:if test="${rent.two_way_yn == 'N'}">checked="checked"</c:if>>
												<label class="form-check-label" for="two_way_yn_n">편도</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="two_way_yn_y" name="two_way_yn" value="Y" <c:if test="${rent.two_way_yn == 'Y'}">checked="checked"</c:if>>
												<label class="form-check-label" for="two_way_yn_y">왕복</label>
											</div>
										</div>
									</div>
								</td>
								<th class="text-right">서류</th>
								<td colspan="3">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" name="contract_make_yn_check" id="contract_make_yn_check" value="Y" <c:if test="${rent.contract_make_yn == 'Y'}">checked="checked"</c:if>>
										<label class="form-check-label" for="contract_make_yn_check">계약서작성</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" name="id_copy_yn_check" id="id_copy_yn_check" value="Y" <c:if test="${rent.id_copy_yn == 'Y'}">checked="checked"</c:if>>
										<label class="form-check-label" for="id_copy_yn_check">신분증사본</label>
									</div>
								</td>	
							</tr>
							<tr>
								<th class="text-right r1s">배송지</th>
								<td colspan="7">
									<div class="form-row inline-pd dc">
                                        <div class="col-1 pdr0">
                                            <input type="text" class="form-control mw45" readonly="readonly" alt="배송지 우편주소"
                                                   id="delivery_post_no" name="delivery_post_no"
                                                   value="${rent.delivery_post_no}">
                                        </div>
                                        <div class="col-auto pdl5">
                                            <button type="button" class="btn btn-primary-gra full"
                                                    onclick="javascript:openSearchAddrPanel('fnSetArrival1Addr');">주소찾기
                                            </button>
                                        </div>
                                        <div class="col-5">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   id="delivery_addr1" name="delivery_addr1"
                                                   value="${rent.delivery_addr1}">
                                        </div>
                                        <div class="col-4">
                                            <input type="text" class="form-control" id="delivery_addr2"
                                                   name="delivery_addr2" value="${rent.delivery_addr2}">
                                        </div>
                                    </div>											
								</td>
							</tr>
							<tr>
								<th class="text-right rs">실 사용지역</th>
								<td colspan="3">
									<div>
										<select class="form-control width130px rb inline" id="sale_area_code" name="sale_area_code" required="required" alt="실 사용지역">
											<option value="">- 선택 -</option>
											<c:forEach items="${areaList}" var="item">
												<option value="${item.sale_area_code}" <c:if test="${item.sale_area_code eq rent.sale_area_code}">selected="selected"</c:if>>${item.sale_area_name}</option>
											</c:forEach>
										</select>
									</div>
								</td>
								<th class="text-right rs">장비용도</th>
								<td>
									<div>
										<select class="form-control rb" id="mch_use_cd" name="mch_use_cd" required="required" alt="장비용도">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['MCH_USE']}" var="mchItem">
												<option value="${mchItem.code_value}" <c:if test="${mchItem.code_value eq rent.mch_use_cd}">selected="selected"</c:if>>${mchItem.code_name}</option>
											</c:forEach>
										</select>
									</div>
								</td>
								<th class="text-right">사용목적</th>
								<td>
									<div>
										<input type="text" class="form-control" maxlength="50" alt="" id="use_purpose" name="use_purpose" value="${rent.use_purpose }">
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">임차구분</th>
								<td colspan="3">
									<div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="norm_rental_yn_check" name="norm_rental_yn_check" value="Y" <c:if test="${rent.norm_rental_yn == 'Y'}">checked="checked"</c:if>>
											<label class="form-check-label" for="norm_rental_yn_check">일반</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="long_rental_yn_check" name="long_rental_yn_check" value="Y" <c:if test="${rent.long_rental_yn == 'Y'}">checked="checked"</c:if>>
											<label class="form-check-label" for="long_rental_yn_check">장기</label>
										</div>
									</div>
								</td>
								<th class="text-right">렌탈계산식</th>
								<td style="font-size: 11px" colspan="3">최종렌탈료=A+B-C+D (직배송 또는 선결제일 경우에만 D 합산)</td>
								<%-- <th class="text-right">운임비</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="transport_amt" name="transport_amt" format="decimal" value="${rent.transport_amt}"  onchange="javascript:fnCalc()" disabled="disabled">
										</div>
										<div class="col width16px">원</div>
										<!-- <span style="color: red">직배송 출고시,렌탈료에 포함</span> -->
									</div>
								</td> --%>
							</tr>
							<tr>
								<%-- <th class="text-right">최소렌탈료</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="min_rental_price" name="min_rental_price" format="decimal" value="${rent.min_rental_price }">
										</div>
										<div class="col width16px">원</div>
									</div>									
								</td> --%>
								<th class="text-right">장비렌탈료</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="machine_rental_price" name="machine_rental_price" format="decimal" value="${rent.machine_rental_price }">
										</div>
										<div class="col width16px">원</div>
										(A)
									</div>									
								</td>
								<th class="text-right">어태치렌탈료</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width80px">
											<input type="text" class="form-control text-right" readonly="readonly" id="attach_rental_price" name="attach_rental_price" format="decimal" value="${rent.attach_rental_price}">
										</div>
										<div class="col width16px">원</div>
										(B)
									</div>									
								</td>
								<th class="text-right">장비보증금</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width80px">
											<input type="text" class="form-control text-right" id="mch_deposit_amt" name="mch_deposit_amt" format="minusNum" onchange="javascript:fnCalc()" value="${rent.mch_deposit_amt}">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<%-- <th class="text-right">어태치렌탈료</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="attach_rental_price" name="attach_rental_price" format="decimal" value="${rent.attach_rental_price}">
										</div>
										<div class="col width16px">원</div>
									</div>									
								</td> --%>
								<th class="text-right">총렌탈료</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="total_rental_amt" name="total_rental_amt" format="decimal" value="${rent.total_rental_amt }">
										</div>
										<div class="col width16px">원</div>
										(A+B)
									</div>									
								</td>
								<th class="text-right">렌탈료조정</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="discount_amt" name="discount_amt" format="minusNum" value="${rent.discount_amt}" onchange="javascript:fnCalc()">
										</div>
										<div class="col width16px">원</div>
										(C) 양수=할인, 음수=할증
									</div>									
								</td>
							</tr>
							<tr>
								<th class="text-right">운임비</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="transport_amt" name="transport_amt" format="decimal" value="${rent.transport_amt}"  onchange="javascript:fnCalc()" disabled="disabled">
										</div>
										<div class="col width16px">원</div>
										<span style="color: red">(D) 직배송,선결제시 최종렌탈료에 합산</span>
									</div>
								</td>
								<th class="text-right">최종렌탈료</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="rental_amt" name="rental_amt" format="decimal" value="${rent.rental_amt}">
										</div>
										<div class="col width16px">원</div>
										<div style="margin-left: 5px;">VAT포함 :<div style="display: inline-block;"><input class="form-control" type="text" id="vat_rental_amt" name="vat_rental_amt" format="decimal" readonly="readonly" value="${rent.vat_rental_amt }"></div></div>
									</div>									
								</td>
							</tr>
							<tr>
								<th class="text-right">비고</th>
								<td colspan="3">
									<textarea class="form-control" style="height: 100%; min-height: 70px" id="remark" name="remark">${rent.remark }</textarea>
								</td>
								<c:if test="${not empty shareList }"> <!-- 상세부터는 테이블에 저장된 정보를 사용함, 코드 사용안함!(코드가 중간에 변경될수도있음) -->
									<th class="text-right">수익배분</th>
									<td colspan="3">
										<table style="border-collapse: collapse;">
											<colgroup>
												<col width="33.33%">
												<col width="33.33%">
												<col width="33.33%">
											</colgroup>
										   <c:forEach items="${shareList}" var="item">
										      <tr>
										         <td>
													 <c:if test="${item.rental_profit_share_type_cd eq '02'}">
														<div style="display: inline-block;">${item.kor_name} (${item.profit_rate }%)</div>
													 </c:if>
													 <c:if test="${item.rental_profit_share_type_cd ne '02'}">
														 <div style="display: inline-block;">${item.rental_profit_share_type_name} (${item.profit_rate }%)</div>
													 </c:if>
										            <input type="hidden" name="rental_profit_share_type_cd_${item.rental_profit_share_type_cd}" value="${item.rental_profit_share_type_cd}">
										            <input type="hidden" name="profit_rate_${item.rental_profit_share_type_cd}" value="${item.profit_rate}">
										         </td>
										         <td>
										         	<fmt:formatNumber type="number" maxFractionDigits="3" value="${item.profit_amt}" />
										         </td>
										         <td>
										         	<%-- <select class="form-control rb" id="profit_mem_no_${item.rental_profit_share_type_cd}" name="profit_mem_no_${item.rental_profit_share_type_cd}" alt="${item.rental_profit_share_type_name }" required="required">
										         		<option value="">- 선택 - </option>
										         		<c:forEach items="${centerMemList}" var="innerItem">
										         			<option value="${innerItem.mem_no }" ${item.mem_no eq innerItem.mem_no ? 'selected' : ''}>${innerItem.mem_name }</option>
										         		</c:forEach>
										         	</select> --%>
										         	<div class="input-group">
<%--														<select class="form-control width130px rb inline" id="profit_org_code_${item.code_value}" name="profit_org_code_${item.code_value}" required="required" alt="${item.code_name}">--%>
<%--															<option value="">- 선택 -</option>--%>
<%--															<c:forEach items="${orgCenterList}" var="listItem">--%>
<%--																<option value="${listItem.org_code}" <c:if test="${listItem.org_code eq item.org_code}">selected="selected"</c:if>>${listItem.org_name}</option>--%>
<%--															</c:forEach>--%>
<%--														</select>--%>
														<input type="text" class="form-control border-right-0" id="profit_mem_name_${item.rental_profit_share_type_cd}" name="profit_mem_name_${item.rental_profit_share_type_cd}" placeholder="직원을조회하세요" value="${item.mem_name}" readonly="readonly" style="background: white" alt="${item.rental_profit_share_type_name}">
														<input type="hidden" id="profit_mem_no_${item.rental_profit_share_type_cd}" name="profit_mem_no_${item.rental_profit_share_type_cd}" value="${item.mem_no}" required="required" alt="${item.rental_profit_share_type_name}">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMemberPanel('fnSetProfit${item.rental_profit_share_type_cd}')"><i class="material-iconssearch"></i></button>
													</div>
										         </td>
										      </tr>
										   </c:forEach>
										</table>
									</td>
									<%-- <td class="">
										<table style="border-collapse: collapse; border: none;">
										   <c:forEach items="${shareList}" var="item">
										      <tr>
										         <td>
										            <div style="display: inline-block;">${item.rental_profit_share_type_name} (${item.profit_rate }%)</div>
										            <input type="hidden" name="rental_profit_share_type_cd_${item.rental_profit_share_type_cd}" value="${item.rental_profit_share_type_cd}">
										            <input type="hidden" name="profit_rate_${item.rental_profit_share_type_cd}" value="${item.profit_rate}">
										         </td>
										         <td>
										         	<fmt:formatNumber type="number" maxFractionDigits="3" value="${item.profit_amt}" />
										         </td>
										         <td>
										         	<div id="profit_mem_name_${item.rental_profit_share_type_cd}">${item.mem_name }</div>
										         	<input type="hidden" id="profit_mem_no_${item.rental_profit_share_type_cd}" name="profit_mem_no_${item.rental_profit_share_type_cd}" value="${item.mem_no}">
										         </td>
										         <td>
										            <div style="display: inline-block;">
										               <button type="button" class="btn btn-default" onclick="javascript:openMemberOrgPanel('fnSetProfit${item.rental_profit_share_type_cd}', 'N')"><i class="material-iconsadd text-default"></i>직원변경</button>
										            </div>
										         </td>
										      </tr>
										   </c:forEach>
										</table>
									</td> --%>
								</c:if>
							</tr>
						</tbody>
					</table>
<!-- /렌탈정보 -->	
				</div>
				<div class="col-6">
<!-- 어태치먼트 -->
					<div class="title-wrap">
						<h4>어태치먼트</h4>
<%--						<div style="display: flex;">--%>
<%--							<div style="line-height: 2; margin-right: 5px">[기본수량]</div>--%>
<%--							<div>--%>
<%--								<span style="margin-right: 3px; line-height: 2"> 대</span>--%>
<%--								<input type="text" class="form-control width24px cInput" id="big_bucket_cnt" name="big_bucket_cnt" alt="대버켓 숫자" value="${rent.big_bucket_cnt}" datatype="int">--%>
<%--							</div>--%>
<%--							<div class="vl">|</div>--%>
<%--							<div>--%>
<%--								<span style="margin-right: 3px; line-height: 2"> 중</span>--%>
<%--								<input type="text" class="form-control width24px cInput" id="mid_bucket_cnt" name="mid_bucket_cnt" alt="중버켓 숫자" value="${rent.mid_bucket_cnt}" datatype="int">--%>
<%--							</div>--%>
<%--							<div class="vl">|</div>--%>
<%--							<div>--%>
<%--								<span style="margin-right: 3px; line-height: 2"> 소</span>--%>
<%--								<input type="text" class="form-control width24px cInput" id="sml_bucket_cnt" name="sml_bucket_cnt" alt="소버켓 숫자" value="${rent.sml_bucket_cnt}" datatype="int">--%>
<%--							</div>--%>
<%--							<div class="vl">|</div>--%>
<%--							<div>--%>
<%--								<span style="margin-right: 3px; line-height: 2"> 키</span>--%>
<%--								<input type="text" class="form-control width24px cInput" id="key_cnt" name="key_cnt" alt="키 숫자" value="${rent.key_cnt}" datatype="int">--%>
<%--							</div>--%>
<%--						</div>--%>
						<button type="button" class="btn btn-primary-gra" onclick="javascript:goAttachPopup();">어태치먼트 현황</button>
					</div>
					<div style="margin-top: 5px; height: 336px;"  id="auiGrid"  ></div>					
<!-- /어태치먼트 -->
					<!-- 계약정보 -->
					<div class="title-wrap">
						<h4>계약정보</h4>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="250px">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">전자계약</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col-auto">
										<button type="button" class="btn btn-primary-gra mr5"  onclick="javascript:sendModusignPanel()" id="_sendModusignPanel"
												<c:if test="${!(empty rent.modusign_id and page.add.MODUSIGN_YN eq 'Y')}">style="display:none;"</c:if>>발송</button>
										<button type="button" class="btn btn-primary-gra"  onclick="javascript:sendContactModusignPanel()" id="_sendContactModusignPanel"
												<c:if test="${!(empty rent.modusign_id and page.add.MODUSIGN_YN eq 'Y')}">style="display:none;"</c:if>>고객앱전송</button>
										<c:if test="${not empty rent.modusign_id and page.add.MODUSIGN_YN eq 'Y' and modusignMap.sign_proc_yn eq 'Y'}">
											<button type="button" class="btn btn-primary-gra"  onclick="javascript:void();" disabled>${modusignMap.modusign_status_label}</button>
											<button type="button" class="btn btn-primary-gra ml5" onclick="javascript:sendModusignCancel()">싸인취소</button>
										</c:if>
										<c:if test="${modusignMap.file_seq ne 0}">
											<a href="javascript:fileDownload('${modusignMap.file_seq}');" style="color: blue; vertical-align: middle;" id="_file_name">${modusignMap.file_name}</a>
											<c:if test="${page.add.MODUSIGN_YN eq 'Y' and modusignMap.modu_modify_yn eq 'N'}">
												<button type="button" class="btn btn-primary-gra ml5" onclick="javascript:fnModusignModify()" id="_fnModusignModify">수정</button>
											</c:if>
										</c:if>
									</div>
									<c:if test="${modusignMap.modu_modify_yn eq 'Y'}">
										<div class="col-auto">(수정중)</div>
									</c:if>
								</div>
							</td>
							<th class="text-right">종이계약서</th>
							<td class="paper_file_td">
								<div class="paper_file_div">
								</div>
								<button type="button" class="btn btn-primary-gra" id="paperFileBtn" onclick="javascript:fnAddFile()" >파일찾기</button>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /계약정보 -->
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->


</form>
</body>
</html>